function[result,msg]=postApply(this)





    result=true;
    msg='';
    userdata=this.cbinfo.userdata;
    userdata.prop.checkIDs=this.getSelectedCheckIDs();
    if~isempty(userdata.prop.checkIDs)
        exclusionEditor=userdata.exclusionEditor;
        exclusionEditor.show;
        exclusionEditor.addExclusionPropToState(userdata.prop,[]);
    end
