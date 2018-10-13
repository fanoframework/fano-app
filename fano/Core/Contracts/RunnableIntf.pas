{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit RunnableIntf;

interface

type
    {------------------------------------------------
     interface for any class that can be run
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRunnable = interface
        ['{C5B758F0-D036-431C-9B69-E49B485FDC80}']
        function run() : IRunnable;
    end;

implementation

end.
