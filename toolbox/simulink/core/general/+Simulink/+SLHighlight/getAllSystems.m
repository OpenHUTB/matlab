function objs=getAllSystems(bh)






    n=length(bh);
    parentO=[];

    for i=1:n

        bhObj=get_param(bh(i),'Object');

        parentO=[parentO;bh(i)];

        p=bhObj.Parent;

        pO=get_param(p,'Object');

        while~strcmp(pO.Type,'block_diagram')

            if isSubSystem(p)
                parentO=[parentO;pO.handle];
            end
            p=pO.parent;
            pO=get_param(p,'Object');
        end
    end

    objs=unique(parentO);

end

function y=isSubSystem(HBlk)

    y=false;

    OBlk=get_param(HBlk,'Object');


    if(strcmp(OBlk.BlockType,'SubSystem'))
        y=true;
    end
end
