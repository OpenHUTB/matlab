function hRoot=getParentModel(this)





    try





        if slfeature('slPbcModelRefEditorReuse')

            mdlHandle=Simulink.scopes.getTopLevelMdl(this.BlockHandle.handle);
            par=get_param(mdlHandle,'Name');
        else
            par=this.BlockHandle.Parent;
            indx=strfind(par,'/');
            if~isempty(indx)
                par=par(1:indx-1);
            end
        end

        hRoot=get_param(par,'Object');
    catch ME %#ok<NASGU>


        hRoot='';
    end


