{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit SimpleRegexRouteListImpl;

interface

{$H+}

uses
    RouteListIntf,
    HashListImpl,
    RegexIntf;

type
    TSimplePlaceholder = record
        phName : string;
        phValue : string;
    end;
    TArrayOfSimplePlaceholders = array of TSimplePlaceholder;

    {------------------------------------------------
     class that store list of routes patterns and its associated data
     and match uri to retrieve matched patterns and its data

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TSimpleRegexRouteList = class(THashList, IRouteList)
    private
        regex : IRegex;

        function getPlaceholderFromOriginalRoute(
            const originalRouteWithRegex : string
        ) : TArrayOfSimplePlaceholders;

        function getPlaceholderValuesFromUri(
            const uri : string;
            const placeHolders : TArrayOfSimplePlaceholders
        ) : TArrayOfSimplePlaceholders;

        procedure clearRoutes();
        function findRoute(const requestUri : string) : pointer;
        function combineRegexRoutes() : string;
        function findMatchedRoute(const matchResult : TRegexMatchResult) : string;
    public
        constructor create(const regexInst : IRegex);
        destructor destroy(); override;

        function add(const routeName : string; const routeData : pointer) : integer;

        (*------------------------------------------------
         * match request uri with route list and return
         * its associated data
         *---------------------------------------------------*)
        function find(const requestUri : string) : pointer;
    end;

implementation

uses

    ERouteMatcherImpl;

resourcestring

    sTotalPlaceHolderAndValueNotEqual = 'Number of variable placeholders (%d) and values (%d) not equal.';

const
    (*-------------------------------------------------
      regex pattern that will match following string format
      and extract placeholder variable name inside {}

      /store/{ storeId }/feedback
      /name/{name-id}/{unitId}/edback
      /name/{name}/{unitId}/edback
      /name/{ tr }/{unitId}/edback

      This class DOES NOT support syntax such as
      /store/{storeId:[a-zA-Z0-9]+}/feedback
    -------------------------------------------------*)
    ROUTE_PLACEHOLDER_REGEX = '\{\s*([a-zA-Z_][a-zA-Z0-9_\-]*)\s*\}';

    (*-------------------------------------------------
      regex pattern that will be used to replace original
      route pattern. The replaced route pattern md5-hashed
      will be stored inside list
    -------------------------------------------------*)
    ROUTE_DISPATCH_REGEX = '([^/]+)';

type

    TRouteDataRec = record
        placeholders: TArrayOfSimplePlaceholders;
        routeData : pointer;
    end;
    PRouteDataRec = ^TRouteDataRec;

    (*------------------------------------------------
     * get placeholder variable original
     *------------------------------------------------
     * for example for route pattern :
     *  /name/{name}/{unitId}/edback
     *
     *  It will returns array of placeholder like below
     *
     * [
     *  {
     *    phName : 'name',
     *    phValue : '',
     *  }
     *  {
     *    phName : 'unitId',
     *    phValue : '',
     *  }
     * ]
     *
     * This method will be called when a route pattern is
     * added to route collection. At this time,
     * placeholder value is not yet known ,so phValue field
     * will always be empty
     *
     *---------------------------------------------------*)
    function TSimpleRegexRouteList.getPlaceholderFromOriginalRoute(
        const originalRouteWithRegex : string
    ) : TArrayOfSimplePlaceholders;
    var matches : TRegexMatchResult;
        i, totalMatches : integer;
    begin
        matches := regex.greedyMatch(
            ROUTE_PLACEHOLDER_REGEX,
            originalRouteWithRegex
        );

        if (not matches.matched) then
        begin
            setlength(result, 0);
            exit;
        end;

        totalMatches := length(matches.matches);
        (*----------------------------
          if route is registered as:
          /name/{name}/{unitId}/edback

          matches will contain following data:

          length(matches.matches) == 3
          matches.matched = true
          matches.matches[0][0] = '/name/{name}/{unitId}/edback'

          matches.matches[1][0] = '{name}'
          matches.matches[1][1] = 'name'

          matches.matches[2][0] = '{unidId}'
          matches.matches[2][1] = 'unitId'

          So to extract variable names, we
          only need to extract from

          matches.matches[n][1]
          where n=1..length(matches.matches)-1
         ----------------------------*)
        setLength(result, totalMatches-1);
        for i:=0 to totalMatches-2 do
        begin
            result[i].phName := matches.matches[i+1][1];
            result[i].phValue := '';
        end;
    end;

    (*------------------------------------------------
     * get placeholder value from uri
     *------------------------------------------------
     * after a route is matched, then this method will be
     * called with matched route, original uri and placeholder
     * for example for route pattern :
     *  /name/{name}/{unitId}/edback
     * and actual Request Uri
     * /name/juhara/nice/edback
     *
     *  It will returns array of placeholder like below
     *
     * [
     *  {
     *    phName : 'name'
     *    phValue : 'juhara'
     *  }
     *  {
     *    phName : 'unitId'
     *    phValue : 'nice'
     *  }
     * ]
     *
     *---------------------------------------------------*)
     function TSimpleRegexRouteList.getPlaceholderValuesFromUri(
         const uri : string;
         const placeHolders : TArrayOfSimplePlaceholders
     ) : TArrayOfSimplePlaceholders;
    var matches : TRegexMatchResult;
        i, totalMatches, totalPlaceHolders : longint;
    begin
        matches := regex.greedyMatch(ROUTE_DISPATCH_REGEX, uri);

        if (not matches.matched) then
        begin
            result := placeholders;
            exit;
        end;

        totalPlaceHolders := length(placeholders);
        totalMatches := length(matches.matches);

        if (totalPlaceHolders <> totalMatches) then
        begin
            //Something is wrong as both must be equal!
            raise ERouteMatcher.createFmt(
                sTotalPlaceHolderAndValueNotEqual,
                [totalPlaceHolders, totalMatches]
            )
        end;

        (*----------------------------
          if we get here then placeholders will contain
          data that is same as output getPlaceholderFromOriginalRoute
          So we do not need to call setLength() anymore

          if request uri is
          /name/juhara/nice/edback

          matches will contain following data:

          length(matches.matches) == 3
          matches.matched = true
          matches.matches[0][0] = '/name/juhara/nice/edback'

          matches.matches[1][0] = 'juhara'

          matches.matches[2][0] = 'nice'

          So to extract value names, we
          only need to extract from

          matches.matches[n][0]
          where n=1..length(matches.matches)-1
         ----------------------------*)
        for i:=0 to totalMatches-2 do
        begin
            //placeholders[i].phName already contain variable name
            placeholders[i].phValue := matches.matches[i+1][0];
        end;
        result := placeHolders;
    end;

    constructor TSimpleRegexRouteList.create(const regexInst : IRegex);
    begin
        regex := regexInst;
    end;

    destructor TSimpleRegexRouteList.destroy();
    begin
        inherited destroy();
        clearRoutes();
        regex := nil;
    end;

    procedure TSimpleRegexRouteList.clearRoutes();
    var i, len : integer;
        routeRec : PRouteDataRec;
    begin
        len := count();
        for i := len -1 downto 0 do
        begin
            routeRec := get(i);
            setLength(routeRec^.placeholders, 0);
            routeRec^.routeData := nil;
            dispose(routeRec);
            delete(i);
        end;
    end;

    (*!------------------------------------------------
     * add route pattern to list
     *-------------------------------------------------
     * @param routeName original route as defined by app
     *   /name/{name}/{unitId}/edback
     * @param routeData, pointer to route data (such handler, etc)
     * @return integer index of added item in list
     *-------------------------------------------------
     *
     * If we have following input route name
     *   /name/{name}/{unitId}/edback
     * (1) we will extract placeholder data
     *     into array of placeholder
     *     [
     *         {
     *             phName : 'name',
     *             phValue : ''
     *         },
     *         {
     *             phName : 'unitId'
     *             phValue : ''
     *         }
     *     ]
     * (2) replace route name into new regex string (transformed route name) as
     *   /name/([^/]+)/([^/]+)/edback
     * (3) store transformed route name into list
     *---------------------------------------------------*)
    function TSimpleRegexRouteList.add(const routeName : string; const routeData : pointer) : integer;
    var transformedRouteName : string;
        routeRec : PRouteDataRec;
    begin
        new(routeRec);
        routeRec^.placeholders := getPlaceholderFromOriginalRoute(routeName);
        routeRec^.routeData := routeData;

        (*------------------------------------------------
         * replace original route pattern :
         *   /name/{name:[a-zA-Z0-9\-\*\:]+}/{unitId}/edback
         *
         * into route pattern ready for dispatch
         * /name/[^/]+/[^/]+/edback
         *
         * See ROUTE_DISPATCH_REGEX constant
         *---------------------------------------------------*)
        transformedRouteName := regex.replace(
            ROUTE_PLACEHOLDER_REGEX,
            routeName,
            ROUTE_DISPATCH_REGEX
        );

        result := inherited add(transformedRouteName, routeRec);
    end;

    (*------------------------------------------------
     * combine route regex pattern inside list as one
     * long regex string
     *------------------------------------------------
     * @return combined route regex string
     *-------------------------------------------------
     * For example, if we have following registered route patterns
     *  (1) /name/([^/]+)/([^/]+)/edback
     *  (2) /article/([^/]+)/([^/]+)
     *  (3) /articles/([^/]+)/([^/]+)
     *
     * We will combine all registered route patterns in list into one
     * string regex, in following format
     *
     *  (?:
     *  (/name/([^/]+)/([^/]+)/edback)|
     *  (/article/([^/]+)/([^/]+)|
     *  (/articles/([^/]+)/([^/]+)
     *  )
     *
     * This is done so we can match all routes using only one
     * regex matching call.
     *  (?:) is non capturing group so only inside parenthesis
     * that will be captured
     *---------------------------------------------------*)
    function TSimpleRegexRouteList.combineRegexRoutes() : string;
    var i, len : integer;
        routeRegex : string;
    begin
        //if we get here, it is assumed that count will be > 0
        result := '(?:';
        len := count();
        for i := 0 to len-1 do
        begin
            routeRegex := keyOfIndex(i);
            if (i < len-1) then
            begin
                result := result + '(' + routeRegex + ')|';
            end else
            begin
                result := result + '(' + routeRegex + ')';
            end;
        end;
        result := result + ')';
    end;

    function TSimpleRegexRouteList.findMatchedRoute(const matchResult : TRegexMatchResult) : string;
    var i, len : integer;
    begin
        len := length(matchResult.matches);
        for i := 1 to len-1 do
        begin
            if (length(matchResult.matches[i][0]) > 0) then
            begin
                result := matchResult.matches[i][0];
                exit;
            end;
        end;
        result := '';
    end;

    (*------------------------------------------------
     * match request uri with route list
     *------------------------------------------------
     * @param requestUri, original request uri
     * @return routeData of matched route
     *-------------------------------------------------
     * For example, if we have following uri
     *   /name/juhara/nice/edback
     * and following registered route patterns
     *  (1) /name/([^/]+)/([^/]+)/edback
     *  (2) /article/([^/]+)/([^/]+)
     *  (3) /articles/([^/]+)/([^/]+)
     *
     * (i) We will combine all registered route patterns in list into one
     * string regex in form, so we can match all routes using only one
     * regex matching call. (?:) is non capturing group so only inside parenthesis
     * that will be captured
     *
     *  (?:
     *  (/name/([^/]+)/([^/]+)/edback)|
     *  (/article/([^/]+)/([^/]+)|
     *  (/articles/([^/]+)/([^/]+)
     *  )
     *
     * (ii) Based on matched group (the second non empty group),
     * we can get index to the list of routes list.
     * (iii) parse capture group based on its placeholder to get value
     * (iv) return route data with its placeholder data
     *---------------------------------------------------*)
    function TSimpleRegexRouteList.findRoute(const requestUri : string) : pointer;
    var combinedRegex : string;
        matches : TRegexMatchResult;
        matchedRouteRegex : string;
        data :PRouteDataRec;
    begin
        combinedRegex := combineRegexRoutes();
        matches := regex.match(combinedRegex, requestUri);
        if (matches.matched) then
        begin
            matchedRouteRegex := findMatchedRoute(matches);
            if (length(matchedRouteRegex) = 0) then
            begin
                result := nil;
                exit;
            end;
            data := inherited find(matchedRouteRegex);
            if (data <> nil) then
            begin
                result := data^.routeData;
            end else
            begin
                result := nil;
            end;
        end else
        begin
            result := nil;
        end;
    end;

    (*------------------------------------------------
     * match request uri with route list and return
     * its associated data
     *---------------------------------------------------*)
    function TSimpleRegexRouteList.find(const requestUri : string) : pointer;
    begin
        if (count() <> 0) then
        begin
            result := findRoute(requestUri);
        end else
        begin
          result := nil;
        end;
    end;
end.