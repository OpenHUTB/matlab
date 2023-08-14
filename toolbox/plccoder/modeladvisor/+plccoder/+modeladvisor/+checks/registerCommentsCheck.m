function registerCommentsCheck()
%

%   Copyright 2020 The MathWorks, Inc.

    rec = ModelAdvisor.Check('mathworks.PLC.Comments');
    rec.Title = DAStudio.message('plccoder:modeladvisor:CommentsTitle');
    rec.TitleTips = DAStudio.message('plccoder:modeladvisor:CommentsTitleTips');
    rec.LicenseName = {'Simulink_PLC_Coder'};
    rec.CSHParameters.MapKey='plcmodeladvisor';
    rec.CSHParameters.TopicID = rec.ID;
    rec.setCallbackFcn(@plccoder.modeladvisor.helpers.C1_Comments,'None','StyleTwo');
    rec.ListViewVisible = false;
    mdladvRoot = ModelAdvisor.Root;
    mdladvRoot.publish(rec, [DAStudio.message('plccoder:modeladvisor:ProductName') '|' DAStudio.message('plccoder:modeladvisor:IndustryStandardChecksName')]);
end
