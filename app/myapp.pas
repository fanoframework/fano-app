(*!------------------------------------------------------------
 * Fano Web Framework Skeleton Application (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano-app
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano-app/blob/master/LICENSE (GPL 3.0)
 *------------------------------------------------------------- *)
unit myapp;

interface

uses

    fano;

type

    TMyApp = class(TFanoWebApplication)
    protected
        procedure buildDependencies(const container : IDependencyContainer); override;
        procedure buildRoutes(const container : IDependencyContainer); override;
        function initDispatcher(const container : IDependencyContainer) : IDispatcher; override;
    end;

implementation

uses
    sysutils,

    {*! -------------------------------
        controllers factory
    ----------------------------------- *}
    HelloControllerFactory,
    HelloJsonControllerFactory,
    HiControllerFactory;


    procedure TMyApp.buildDependencies(const container : IDependencyContainer);
    begin
        {$INCLUDE Dependencies/dependencies.inc}
    end;

    procedure TMyApp.buildRoutes(const container : IDependencyContainer);
    var router : IRouteCollection;
    begin
        router := container.get('router') as IRouteCollection;
        try
            {$INCLUDE Routes/routes.inc}
        finally
            router := nil;
        end;
    end;

    function TMyApp.initDispatcher(const container : IDependencyContainer) : IDispatcher;
    begin
        result := container.get('dispatcher') as IDispatcher;
    end;
end.
