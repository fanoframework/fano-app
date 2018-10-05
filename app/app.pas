{-----------------------------------------------
 Bootstrap application
 @author Zamrony P. Juhara <zamronypj@yahoo.com>
------------------------------------------------}
program app;

uses
    AppIntf,
    AppImpl,
    ConfigIntf,
    RouteCollectionIntf,
    EnvironmentIntf,
    DispatcherIntf,

    {------------------------------------
    Register application dependencies
    -------------------------------------}
    di,

    {------------------------------------
    Register application routes
    -------------------------------------}
    routes;

var
    {------------------------------------
    global application instance
    -------------------------------------}
    appInstance : IWebApplication;

begin
    try
        appInstance := TFanoWebApplication.create(
            appDependencyContainer.get('config') as IAppConfiguration,
            appDependencyContainer.get('dispatcher') as IDispatcher,
            appDependencyContainer.get('environment') as ICGIEnvironment,
            appDependencyContainer.get('router') as IRouteCollection,
            appDependencyContainer
        );
        appInstance.run();
    finally
        appInstance := nil;
    end;
end.
