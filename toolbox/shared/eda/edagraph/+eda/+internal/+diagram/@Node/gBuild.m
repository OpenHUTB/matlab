function gBuild(Obj,DUT)







    if nargin<2
        DUT='';
    end

    Obj.componentInit;

    if isa(Obj,'eda.internal.component.WhiteBox')
        if isempty(Obj.findprop('IsAlreadyConstructed'))
            Obj.implement;
            Obj.addprop('IsAlreadyConstructed');

            if isa(DUT,'eda.internal.component.Component')
                Obj.ChildNode{end+1}=DUT;
                Obj.addChildren(DUT);
            end
        end
    end



    compList=Obj.ChildNode;

    for i=1:length(compList)
        comp=compList{i};
        if(isa(comp,'eda.internal.component.WhiteBox'))
            gBuild(comp);
        else
            comp.componentInit;
        end
    end


end
