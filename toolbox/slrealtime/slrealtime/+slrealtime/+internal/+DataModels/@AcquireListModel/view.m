function view(this)





    for ag=1:this.nAcquireGroups
        AcuireGroup=this.AcquireGroups(ag);
        fprintf('Acquire Group %2d\n',ag)
        AcuireGroup.view;
    end

end
