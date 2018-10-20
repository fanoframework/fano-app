{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit ViewParametersFactoryImpl;

interface

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    (*!------------------------------------------------
     * class having capability to create view parameters
     * instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TViewParametersFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    ViewParametersImpl;

    function TViewParametersFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TViewParameters.create();
    end;
end.