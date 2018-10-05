unit RequestFactoryIntf;

interface

uses
    EnvironmentIntf,
    RequestIntf;

type
    {------------------------------------------------
     interface for any class having capability
     to build request instance
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRequestFactory = interface
        ['{C4015735-B800-4F0B-BF35-C7900D5135E7}']
        function build(const env : ICGIEnvironment) : IRequest;
    end;

implementation
end.
