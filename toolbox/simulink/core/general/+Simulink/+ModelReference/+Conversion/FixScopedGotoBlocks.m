classdef FixScopedGotoBlocks<Simulink.ModelReference.Conversion.GotoFromFix




    properties(SetAccess=private,GetAccess=private)
SubsystemConversionCheck
gotoTagVisibility
    end

    methods(Access=public)
        function this=FixScopedGotoBlocks(subsys,gotoBlocks,portInfos,params,check,portInfoMap,gotoTagVisibility)
            this@Simulink.ModelReference.Conversion.GotoFromFix(subsys,gotoBlocks,portInfos,params,portInfoMap);
            this.SubsystemConversionCheck=check;
            this.gotoTagVisibility=gotoTagVisibility;
            this.IsModifiedSystemInterface=false;
        end
    end


    methods(Access=protected)
        function update(this,subsysH,gotoTagVisibility,~)
            subsysIndex=this.ConversionData.ConversionParameters.Systems==subsysH;
            newModelName=this.ConversionData.ConversionParameters.ModelReferenceNames{subsysIndex};
            newModel=get_param(newModelName,'Handle');
            modelBlock=this.ConversionData.ModelBlocks(subsysIndex);
            [x_pos,y_pos]=Simulink.ModelReference.Conversion.GotoFromFix.guessInitialPosition(newModel);
            [portWidth,portHeight]=Simulink.ModelReference.Conversion.GotoFromFix.guessPortSize(newModel,'GotoTagVisibility');
            for ii=1:numel(gotoTagVisibility)
                destScopeBlk=sprintf('%s/GotoScopeBlk_%d',newModelName,ii);
                newPos=[x_pos,y_pos,x_pos+portWidth,y_pos+portHeight];
                newBlkH=add_block(gotoTagVisibility,destScopeBlk,'Position',rtwprivate('sanitizePosition',newPos),'ShowName','off');
                set_param(newBlkH,'Name',get_param(gotoTagVisibility,'Name'));
                x_pos=x_pos+30;
            end
        end
    end
end
