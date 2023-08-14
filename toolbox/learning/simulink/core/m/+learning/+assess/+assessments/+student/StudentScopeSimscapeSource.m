classdef StudentScopeSimscapeSource<learning.assess.assessments.StudentAssessment



    properties(Constant)
        type='ScopeSimscapeSource';
    end

    properties
SimscapeBlock
    end

    methods
        function obj=StudentScopeSimscapeSource(props)
            obj.validateInput(props);
            obj.SimscapeBlock=props.SimscapeBlock;
        end

        function isCorrect=assess(obj,userModelName)
            isCorrect=false;

            scopeBlock=Simulink.findBlocks(userModelName,'BlockType','Scope');

            if isempty(scopeBlock)
                return
            else


                for idx=1:numel(scopeBlock)
                    scopePortConn=get_param(scopeBlock(idx),'PortConnectivity');

                    portSources=cell(size(scopePortConn));

                    for jdx=1:numel(scopePortConn)
                        portSources{jdx}=obj.getPSSource(scopePortConn(jdx));
                    end

                    isCorrect=any(contains(portSources,obj.SimscapeBlock));
                    if isCorrect
                        break
                    end
                end
            end

        end

        function requirementString=generateRequirementString(obj)
            fullBockPath=strsplit(obj.SimscapeBlock,'/');
            blockType=fullBockPath{end};

            requirementString=message('learning:simulink:genericRequirements:simscapeSource',...
            blockType).getString();
        end
    end

    methods(Access=protected)
        function validateInput(~,props)
            if isempty(props.SimscapeBlock)||~(ischar(props.SimscapeBlock)||isstring(props.SimscapeBlock))
                error(message('learning:simulink:resources:InvalidInput'));
            end
        end

        function srcBlockName=getPSSource(~,scopeConnection)


            srcBlock=scopeConnection.SrcBlock;
            if srcBlock==-1
                srcBlockName='';
                return
            end
            srcHands=get_param(srcBlock,'PortHandles');


            isPsSimulink=strcmp(get_param(srcBlock,'ReferenceBlock'),['nesl_utility/PS-Simulink',newline,'Converter']);
            if~isfield(srcHands,'LConn')||~isPsSimulink
                srcBlockName='';
                return
            else
                psLineHand=get_param(srcHands.LConn,'Line');
                if psLineHand==-1
                    srcBlockName='';
                    return
                end
                srcBlockHand=get_param(psLineHand,'SrcBlockHandle');
                if srcBlockHand==srcBlock
                    srcBlockHand=get_param(psLineHand,'DstBlockHandle');
                end
                srcBlockName=get_param(srcBlockHand,'ReferenceBlock');
            end
        end
    end

end
