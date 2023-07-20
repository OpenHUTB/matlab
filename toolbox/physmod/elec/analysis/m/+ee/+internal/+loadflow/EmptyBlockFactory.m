function block=EmptyBlockFactory(block,varargin)




    className=class(block);
    if isa(block,'ee.internal.loadflow.Block')
        switch className
        case 'ee.internal.loadflow.Busbar'
            block=ee.internal.loadflow.Busbar.empty;
        case 'ee.internal.loadflow.BusbarDC'
            block=ee.internal.loadflow.BusbarDC.empty;
        case 'ee.internal.loadflow.ConstantImpedanceLoad'
            block=ee.internal.loadflow.ConstantImpedanceLoad.empty;
        case 'ee.internal.loadflow.InductionMachine'
            block=ee.internal.loadflow.InductionMachine.empty;
        case 'ee.internal.loadflow.LoadFlowSource'
            block=ee.internal.loadflow.LoadFlowSource.empty;
        case 'ee.internal.loadflow.SynchronousMachine'
            block=ee.internal.loadflow.SynchronousMachine.empty;
        case 'ee.internal.loadflow.Transformer'
            block=ee.internal.loadflow.Transformer.empty;
        case 'ee.internal.loadflow.TransmissionLine'
            block=ee.internal.loadflow.TransmissionLine.empty;
        otherwise
            error(message('physmod:ee:loadflow:UnrecognizedSubclassEmptyBlockFactory',className));
        end
    else
        error(message('physmod:ee:loadflow:SubclassEmptyBlockFactory',className));
    end
end