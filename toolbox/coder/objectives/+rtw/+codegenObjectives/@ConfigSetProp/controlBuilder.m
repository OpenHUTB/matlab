function controlBuilder(obj)



    control=obj.controlList;
    obj.nOfCC=1;


    for i=1:obj.nOfCC
        ctrl.id=control.id{i};
        ctrl.name=control.name{i};
        ctrl.len=control.len{i};
        obj.CtrlCond{i}=ctrl;

        for j=1:control.len{i}
            obj.CtrlCond{i}.param{j}.id=control.params{i}{j}.id;
            obj.CtrlCond{i}.param{j}.setting=control.params{i}{j}.setting;
        end
    end

    obj.stateOfCC{1}='ERTTarget';
    obj.stateOfCC{2}='~ERTTarget';
end
