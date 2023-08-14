classdef InterfaceSize<metric.SimpleMetric



    properties

    end

    methods
        function obj=InterfaceSize()
            obj.AlgorithmID='slcomp.InterfacePorts';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64Vector);
            obj.Version=1;
        end

        function res=algorithm(this,resultFactory,component)

            res=resultFactory.createResult(this.ID,component);
            n_inports=0;
            n_outports=0;
            if strcmp(component.Type,'sl_embedded_matlab_fcn')
                sid=metric.internal.getSIDFromArtifact(component);
                code=metric.internal.getSFScript(sid);
                interface_size=metric.internal.ca.getMATLABInOutCount(code);
                n_inports=interface_size(1);
                n_outports=interface_size(2);
            elseif strcmp(component.Type,'m_func')||strcmp(component.Type,'m_method')
                code=metric.internal.ca.getMATLABCode(component);
                interface_size=metric.internal.ca.getMATLABInOutCount(code);
                n_inports=interface_size(1);
                n_outports=interface_size(2);
            elseif strcmp(component.Type,'sf_chart')
                slHandle=Simulink.ID.getHandle(metric.internal.getSIDFromArtifact(component));
                sfObj=slHandle;
                if isnumeric(sfObj)
                    tempVar=sfprivate('block2chart',sfObj);
                    sfObj=idToHandle(sfroot,tempVar);
                end
                inports=sfObj.find('-isa','Stateflow.Data','scope','input','-depth',1);
                outports=sfObj.find('-isa','Stateflow.Data','scope','output','-depth',1);
                n_inports=length(inports);
                n_outports=length(outports);
            else
                slHandle=Simulink.ID.getHandle(metric.internal.getSIDFromArtifact(component));
                inports=find_system(slHandle,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','FollowLinks','on',...
                'SearchDepth',1,'BlockType','Inport');

                outports=find_system(slHandle,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','FollowLinks','on',...
                'SearchDepth',1,'BlockType','Outport');
                n_inports=length(inports);
                n_outports=length(outports);
            end
            res.Value=[uint64(n_inports),uint64(n_outports)];
        end
    end
end
