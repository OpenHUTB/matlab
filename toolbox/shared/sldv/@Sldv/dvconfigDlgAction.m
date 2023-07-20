function[ok,msg]=dvconfigDlgAction(hDlg,hObj,action,page)%#ok




    ok=1;
    msg='';

    if~license('test','Simulink_Design_Verifier')||...
        exist('slavteng','builtin')~=5
        return;
    end

    hSrc=hObj.getSourceObject;

    if any(strcmp(action,{'ok','cancel'}))
        if~isempty(hSrc.getModel)
            mdl=getModel(hSrc);
            modelH=get_param(mdl,'Handle');
            sldvcc=sldvprivate('configcomp_get',modelH);
            if~isempty(sldvcc)
                sldvcc.SubsystemToAnalyze=[];
            end
        end
    end




    if any(strcmp(action,{'ok','apply'}))&&strcmp(hObj.IsDialogCache,'on')
        sourceCS=hSrc.getConfigSetSource;
        sldvcc=sourceCS.getComponent('Design Verifier');
        sldvcc.ParameterManager=[];
    end

end

