classdef MLSEEqualizer<matlab.system.SFunSystem



































































































%#function mcommlseeq

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        ChannelSource='Property';







        Channel=[1;0.7;0.5;0.3];





        Constellation=[1+1i,-1+1i,-1-1i,1-1i];









        TracebackDepth=21;

































        TerminationMethod='Truncated';






        PreambleSource='None';









        Preamble=[0,3,2,1];






        PostambleSource='None';









        Postamble=[0,2,3,1];



        SamplesPerSymbol=1;







        ResetInputPort(1,1)logical=false;
    end

    properties(Constant,Hidden)
        TerminationMethodSet=matlab.system.StringSet(...
        {'Continuous','Truncated'});
        PreambleSourceSet=comm.CommonSets.getSet('NoneOrProperty');
        PostambleSourceSet=comm.CommonSets.getSet('NoneOrProperty');
        ChannelSourceSet=comm.CommonSets.getSet('SpecifyInputs');
    end

    methods
        function obj=MLSEEqualizer(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcommlseeq');
            setProperties(obj,nargin,varargin{:},'Channel');
            setVarSizeAllowedStatus(obj,false);
            setForceInputRealToComplex(obj,1,true);
        end
    end

    methods(Hidden)
        function setParameters(obj)

            terminationMethodIdx=getIndex(obj.TerminationMethodSet,...
            obj.TerminationMethod);

            preambleSourceIdx=getIndex(obj.PreambleSourceSet,...
            obj.PreambleSource)-1;
            postambleSourceIdx=getIndex(obj.PostambleSourceSet,...
            obj.PostambleSource)-1;

            channelSourceIdx=3-getIndex(...
            obj.ChannelSourceSet,obj.ChannelSource);


            [errStr,~,cplxconstpts]=commblkmlseeq(obj,'init',2,...
            obj.Channel,obj.Constellation,...
            obj.TracebackDepth,terminationMethodIdx,preambleSourceIdx,...
            obj.Preamble,postambleSourceIdx,obj.Postamble,...
            obj.SamplesPerSymbol,double(obj.ResetInputPort));

            if~isempty(errStr.msg)
                coder.internal.errorIf(true,errStr.mmi);
            end





            obj.compSetParameters({...
            channelSourceIdx,...
            real(obj.Channel),...
            imag(obj.Channel),...
            real(cplxconstpts),...
            imag(cplxconstpts),...
            obj.TracebackDepth,...
            terminationMethodIdx,...
            preambleSourceIdx,...
            obj.Preamble,...
            postambleSourceIdx,...
            obj.Postamble,...
            obj.SamplesPerSymbol,...
            double(obj.ResetInputPort),...
            });
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            if strcmp(obj.TerminationMethod,'Continuous')
                props={'PreambleSource','Preamble','PostambleSource','Postamble'};
            else
                props={'ResetInputPort'};
                if strcmp(obj.PreambleSource,'None')
                    props=[props,{'Preamble'}];
                end
                if strcmp(obj.PostambleSource,'None')
                    props=[props,{'Postamble'}];
                end
            end
            if strcmp(obj.ChannelSource,'Input port')
                props=[props,{'Channel'}];
            end
            flag=ismember(prop,props);
        end

        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commeq3/MLSE Equalizer';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'ChannelSource',...
            'Channel',...
            'Constellation',...
            'TracebackDepth',...
            'TerminationMethod',...
            'ResetInputPort',...
            'PreambleSource',...
            'Preamble',...
            'PostambleSource',...
            'Postamble',...
            'SamplesPerSymbol'};
        end


        function props=getValueOnlyProperties()
            props={'Channel'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end

