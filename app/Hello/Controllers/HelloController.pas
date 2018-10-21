unit HelloController;

interface

uses

    DependencyIntf,
    RequestIntf,
    ResponseIntf,
    ControllerImpl;

type

    THelloController = class(TController, IDependency)
    public
        function handleRequest(
            const request : IRequest;
            const response : IResponse
        ) : IResponse; override;
    end;

implementation

uses

    PlaceholderTypes;

    function THelloController.handleRequest(
          const request : IRequest;
          const response : IResponse
    ) : IResponse;
    var placeHolders : TArrayOfPlaceholders;
        i:integer;
    begin
        placeHolders := getArgs();
        for i:=0 to length(placeholders)-1 do
        begin
            viewParams.setVar(placeholders[i].phName, placeholders[i].phValue);
        end;
        result := inherited handleRequest(request, response);
    end;

end.
