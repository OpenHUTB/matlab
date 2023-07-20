



function arrowheadSizeCB(userdata,cbinfo)
    sizeList=[2,4,6,7,8,9,10,12,14,16,20,24,32,40,48,50];


    selection=cbinfo.selection;
    objects=zeros(1,selection.size);
    for j=1:selection.size
        obj=selection.at(j);
        if obj.backendId~=0
            t=SFStudio.Utils.getType(double(obj.backendId));
            types=SFStudio.Utils.getType;
            if t.type==types.OR_STATE||t.type==types.AND_STATE||...
                t.type==types.BOX||t.type==types.JUNCT||t.type==types.TRANS||t.type==types.PORT




                if t.type==types.TRANS
                    obj=obj.dstElement;
                    if~obj.isvalid
                        continue;
                    end
                end

                objects(j)=obj.backendId;
            end
        end
    end


    objects=unique(objects);


    sizes=zeros(1,length(objects));
    for j=1:length(objects)
        if objects(j)~=0
            obj=StateflowDI.SFDomain.id2DiagramElement(objects(j));
            switch userdata
            case 'grow'
                bigger=sizeList(sizeList>obj.arrowSize);
                if~isempty(bigger)
                    sizes(j)=bigger(1);
                end
            case 'shrink'
                smaller=sizeList(sizeList<obj.arrowSize);
                if~isempty(smaller)
                    sizes(j)=smaller(length(smaller));
                end
            case 'select'
                sizes(j)=str2double(cbinfo.EventData);
            otherwise
                error('Bad option passed to arrowheadSizeCB');
            end
        end
    end


    editor=cbinfo.studio.App.getActiveEditor;
    undoId='Stateflow:studio:SetArrowheadSizeUndo';
    editor.createMCommand(undoId,DAStudio.message(undoId),@loc_setArrowSize,{objects,sizes});
end

function loc_setArrowSize(objects,sizes)
    for j=1:length(objects)
        if objects(j)~=0
            obj=StateflowDI.SFDomain.id2DiagramElement(objects(j));
            if isa(obj,'StateflowDI.State')||isa(obj,'StateflowDI.Junction')||isa(obj,'StateflowDI.Port')
                size=sizes(j);
                if size>0&&size~=obj.arrowSize
                    m=M3I.ImmutableModel.cast(obj.modelM3I.getRootDeviant);
                    obj=obj.asDeviant(m);
                    obj.arrowSize=size;
                end
            end
        end
    end
end
