classdef GraphicalUtils<handle
    methods(Static,Access=public)
        function outportH=addMuxBlock(strucBus,modelName,outportH)

            srcPos=get_param(outportH,'Position');
            numInports=length(outportH);

            if~iscell(srcPos)
                numInports=1;
                tempVar=srcPos;clear srcPos;srcPos{1}=tempVar;
            end

            pos=coder.internal.Utilities.maxCoordinate(srcPos);
            muxPosition=[pos(3)+100,pos(2)-5,pos(3)+105,pos(4)+5];

            muxH=add_block('built-in/BusCreator',...
            [modelName,'/unique_name_for_mux'],...
            'Position',rtwprivate('sanitizePosition',muxPosition),...
            'Inputs',sprintf('%d',numInports));


            tempSID=Simulink.ID.getSID(muxH);


            origSID=[modelName,':0'];




            rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);

            coder.internal.slBus('LocalSetName',muxH,strucBus.name,'Mux');

            portH=get_param(muxH,'PortHandles');

            for i=1:numInports
                add_line(modelName,outportH(i),portH.Inport(i));
            end

            outportH=portH.Outport;
            set_param(outportH,'Name',strucBus.name);
        end
    end
end
