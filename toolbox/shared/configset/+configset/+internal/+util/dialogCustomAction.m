function dialogCustomAction(hController,hSrc,hDlg,action)













    if isa(hSrc,'Simulink.ConfigSet')
        hdlccObj=hSrc.getComponent('HDL Coder');

        if~isempty(hdlccObj)
            hdlcoderui.hdlconfigDlgAction(hDlg,hdlccObj,action,'HDLCoder');
        end

        try
            sldvccObj=hSrc.getComponent('Design Verifier');
            if~isempty(sldvccObj)
                Sldv.dvconfigDlgAction(hDlg,sldvccObj,action,'Design Verifier');
            end
        catch Mex %#ok<NASGU>
        end








        if~isa(hController,'hdlcoderui.hdlcc')
            tdkfpgaObj=hSrc.getComponent('EDA Link');







            if~isempty(tdkfpgaObj)
                tdkfpgaCmd=which('tdkfpgacc.tdkfpgaConfigDlgAction');
                if~isempty(tdkfpgaCmd)
                    tdkfpgacc.tdkfpgaConfigDlgAction(hDlg,tdkfpgaObj,action,'EDA Link');
                end
            end
        end

    end


