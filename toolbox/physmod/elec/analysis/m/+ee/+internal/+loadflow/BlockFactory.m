function block=BlockFactory(block,varargin)




    className=class(block);
    if isa(block,'ee.internal.loadflow.Block')
        switch className
        case 'ee.internal.loadflow.Busbar'
            block=ee.internal.loadflow.Busbar(varargin{:});
        case 'ee.internal.loadflow.BusbarDC'
            block=ee.internal.loadflow.BusbarDC(varargin{:});
        case 'ee.internal.loadflow.ConstantImpedanceLoad'
            block=ee.internal.loadflow.ConstantImpedanceLoad(varargin{:});
        case 'ee.internal.loadflow.InductionMachine'
            block=ee.internal.loadflow.InductionMachine(varargin{:});
        case 'ee.internal.loadflow.LoadFlowSource'
            block=ee.internal.loadflow.LoadFlowSource(varargin{:});
        case 'ee.internal.loadflow.SynchronousMachine'
            block=ee.internal.loadflow.SynchronousMachine(varargin{:});
        case 'ee.internal.loadflow.Transformer'
            block=ee.internal.loadflow.Transformer(varargin{:});
        case 'ee.internal.loadflow.TransmissionLine'
            block=ee.internal.loadflow.TransmissionLine(varargin{:});
        otherwise
            error(message('physmod:ee:loadflow:UnrecognizedSubclassBlockFactory',className));
        end
    else
        error(message('physmod:ee:loadflow:SubclassBlockFactory',className));
    end
end