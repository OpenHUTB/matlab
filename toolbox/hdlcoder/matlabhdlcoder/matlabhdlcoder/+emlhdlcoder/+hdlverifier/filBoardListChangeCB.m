function filBoardListChangeCB




    dt=com.mathworks.project.impl.DeployTool.getInstance(false);
    prj=dt.getProject;
    cfg=prj.getConfiguration;
    selection=cfg.getParamAsString('param.hdl.FILBoardName');
    if strcmpi(selection,message('hdlcoder:hdlverifier:CreateBoard').getString)

        cfg.setParamAsString('param.hdl.FILBoardName',message('hdlcoder:hdlverifier:ChooseBoard').getString);
        h=boardmanagergui.NewBoardWizard('');
        DAStudio.Dialog(h);
    elseif strcmpi(selection,message('hdlcoder:hdlverifier:GetBoard').getString)

        cfg.setParamAsString('param.hdl.FILBoardName',message('hdlcoder:hdlverifier:ChooseBoard').getString);
        matlab.addons.supportpackage.internal.explorer.showSupportPackages({'HDLCVXILINX','HDLVALTERA'},'tripwire');
    end


    cfg.refreshParamOptions('param.hdl.FILConnection');
end

