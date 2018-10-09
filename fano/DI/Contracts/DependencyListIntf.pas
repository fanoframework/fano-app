{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit DependencyListIntf;

interface

uses
    HashListIntf;

type
    {------------------------------------------------
     interface for any class having capability to
     dependencies
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IDependencyList = interface(IHashList)
        ['{BBDB53E2-D4DF-4FD0-86D4-2291124236B1}']
    end;

implementation
end.
