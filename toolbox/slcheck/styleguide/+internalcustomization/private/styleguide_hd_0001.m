function[rec]=styleguide_hd_0001

    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.maab.hd_0001');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:hd_0001_title');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:styleguide:hd_0001_guideline'),newline,newline,DAStudio.message('ModelAdvisor:styleguide:hd_0001_tip')];


    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;
    rec.SupportsEditTime=true;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='hd0001Title';

    rec.setInputParametersLayoutGrid([11,4]);
    inputParam1=ModelAdvisor.InputParameter;
    inputParam1.RowSpan=[1,1];
    inputParam1.ColSpan=[1,2];
    inputParam1.Name=DAStudio.message('ModelAdvisor:engine:Standard');
    inputParam1.Type='Enum';
    inputParam1.Value='MAB';
    inputParam1.Entries={'MAB','Custom'};
    inputParam1.Visible=false;

    inputParam2=ModelAdvisor.InputParameter;
    inputParam2.RowSpan=[1,1];
    inputParam2.ColSpan=[3,4];
    inputParam2.Name=DAStudio.message('ModelAdvisor:engine:BlkListInterpretionMode');
    inputParam2.Type='Enum';
    inputParam2.Value=ModelAdvisor.Common.getDefaultBlkListInterpretionMode_hd_0001;
    inputParam2.Entries={DAStudio.message('ModelAdvisor:engine:Allowed'),DAStudio.message('ModelAdvisor:engine:Prohibited')};
    inputParam2.Visible=false;
    inputParam2.Enable=false;

    inputParam3=ModelAdvisor.InputParameter;
    inputParam3.RowSpan=[2,10];
    inputParam3.ColSpan=[1,4];
    inputParam3.Name=DAStudio.message('ModelAdvisor:engine:BlkTypeList');
    inputParam3.Type='BlockType';
    inputParam3.Value=ModelAdvisor.Common.getDefaultBlockList_hd_0001;
    inputParam3.Visible=false;
    inputParam3.Enable=false;

    inputParam4=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam4.RowSpan=[11,11];
    inputParam4.ColSpan=[1,2];
    inputParam5=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam5.RowSpan=[11,11];
    inputParam5.ColSpan=[3,4];
    inputParam5.Value='graphical';

    rec.setInputParameters({inputParam1,inputParam2,inputParam3,inputParam4,inputParam5});
    rec.setInputParametersCallbackFcn(@ModelAdvisor.Common.blkTypeList_MAAB_InputParamCB);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,sg_maab_group);
end
