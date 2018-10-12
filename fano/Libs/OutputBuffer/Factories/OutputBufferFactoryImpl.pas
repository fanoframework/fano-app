{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit OutputBufferFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyContainerIntf,
    DependencyFactoryIntf,
    FactoryImpl;

type
    {------------------------------------------------
     factory class for TOutputBuffer

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TOutputBufferFactory = class(TFactory, IDependencyFactory)
    public
        function build() : IDependency; override;
    end;

implementation

uses
    OutputBufferImpl;

    function TOutputBufferFactory.build() : IDependency;
    begin
        result := TOutputBuffer.create();
    end;

end.
