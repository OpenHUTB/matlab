classdef TCMDemodulatorBase<matlab.system.SFunSystem





%#function mcomtcmdec

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)

















        TerminationMethod='Continuous';











        TracebackDepth=21;



        OutputDataType='double';








        ResetInputPort(1,1)logical=false;
    end

    properties(Constant,Hidden)
        TerminationMethodSet=comm.CommonSets.getSet('TerminationMethod');
        OutputDataTypeSet=comm.CommonSets.getSet('LogicalOrDouble');
    end

    methods(Abstract,Access=protected)
        [err,cplxconstpts,t]=getInitializationParameters(obj);
    end

    methods(Access=protected)
        function obj=TCMDemodulatorBase(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomtcmdec');
            setProperties(obj,nargin,varargin{:},'TrellisStructure');
            setVarSizeAllowedStatus(obj,false);
            setForceInputRealToComplex(obj,1,true);
        end

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if~strcmp(obj.TerminationMethod,'Continuous')
                props=[props,{'ResetInputPort'}];
            end
            flag=ismember(prop,props);
        end
    end

    methods(Hidden)
        function setParameters(obj)
            terminationMethodIdx=getIndex(obj.TerminationMethodSet,...
            obj.TerminationMethod);
            outputDataTypeIdx=getIndex(obj.OutputDataTypeSet,...
            obj.OutputDataType);

            [err,cplxconstpts,t]=getInitializationParameters(obj);

            if~isempty(err.msg)
                colons=coder.internal.const(strfind(err.mmi,':'));
                final_token=err.mmi(colons(end)+1:end);
                coder.internal.errorIf(true,['comm:system:TCMDemodulator:',final_token]);
            end



            resetPort=0+((terminationMethodIdx==1)&&obj.ResetInputPort);




            obj.compSetParameters({...
            t.k,t.n,t.numStates,t.outputs,t.nextStates,...
            real(cplxconstpts),...
            imag(cplxconstpts),...
            obj.TracebackDepth,...
            terminationMethodIdx,...
            resetPort,...
outputDataTypeIdx...
            });
        end
    end

    methods(Static,Hidden)


        function props=getValueOnlyProperties()
            props={'TrellisStructure'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end
