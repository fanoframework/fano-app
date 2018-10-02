unit MiddlewareIntf;

interface

uses
   RequestHandlerIntf;

type
    {------------------------------------------------
     interface for any class having capability to
     handler route
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IMiddleware = interface (IRequestHandler)
    end;

implementation
end.