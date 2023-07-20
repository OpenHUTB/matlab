function enum=HDLInputOutputTypeEnum(cs,param)





    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('HDL Coder');
    else
        hObj=cs;
    end


    cli=hObj.getCLI;
    language=cli.TargetLanguage;

    if strcmpi(language,'VHDL')
        strs={'std_logic_vector','signed/unsigned'};
        keys={'HDLShared:hdldialog:hdlglblsettingInputSLV','HDLShared:hdldialog:hdlglblsettingInputSigned'};
        if strcmp(param,'OutputType')
            strs=['Same as input type',strs];
            keys=['HDLShared:hdldialog:hdlglblsettingOutputSameAsInput',keys];
        end
        enum=struct('str',strs,'key',keys);
    else
        options={'wire'};
        enum=struct('str',options,'disp',options);
    end

