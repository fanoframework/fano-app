unit RequestHandlerAsMiddlewareImpl;

interface

uses
    RequestIntf,
    ResponseIntf,
    RequestHandlerIntf,
    MiddlewareIntf;

type
    {------------------------------------------------
     adapter class that wrap request handler so it can
     act as a middleware
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TRequestHandlerAsMiddleware = class(TInterfacedObject, IMiddleware)
    private
          requestHandler : IRequestHandler;
    public
        constructor create(requestHandlerInst : IRequestHandler);
        destructor destroy(); override;
        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse;
    end;

implementation

    constructor TRequestHandlerAsMiddleware.create(requestHandlerInst : IRequestHandler);
    begin
        requestHandler := requestHandlerInst;
    end;

    destructor TRequestHandlerAsMiddleware.destroy();
    begin
        inherited destroy();
        requestHandler := nil;
    end;

    function TRequestHandlerAsMiddleware.handleRequest(
        const request : IRequest;
        const response : IResponse;
        var canContinue : boolean
    ) : IResponse;
    begin
        canContinue := true;
        result := requestHandler.handleRequest(request, response);
    end;
end.
