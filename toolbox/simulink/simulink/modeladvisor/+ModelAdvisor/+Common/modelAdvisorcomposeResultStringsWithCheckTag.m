function[retDesc,retDetails]=modelAdvisorcomposeResultStringsWithCheckTag(model,checklist,resultDesc,checkTag,xlateTagPrefix)






    encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(model,'Name'),'encode');
    encodedModelName=[encodedModelName{:}];

    retDetails={1:size(checklist,1)};
    retDesc={1:size(checklist,1)};

    for i=1:size(checklist,1)



        Tag=[xlateTagPrefix,checkTag,'ResultDetails',num2str(i)];
        msgStr=ModelAdvisor.Text(DAStudio.message(Tag,checklist{i,2}),{'fail'});
        Tag=[xlateTagPrefix,checkTag,'HyperLink',num2str(i)];
        linkStr=ModelAdvisor.Text(DAStudio.message(Tag));
        linkStr.setHyperlink(['matlab: modeladvisorprivate openSimprmAdvancedPage ',[encodedModelName,' ''',checklist{i,3},''' ']]);
        retDetails{i}=[msgStr,ModelAdvisor.LineBreak,linkStr];

        ResultDescTag=[xlateTagPrefix,checkTag,'ResultDesc',num2str(i)];
        retDesc{i}=[ModelAdvisor.Text(DAStudio.message(ResultDescTag,checklist{i,2}),{'bold'}),...
        ModelAdvisor.LineBreak...
        ,ModelAdvisor.Text(DAStudio.message([xlateTagPrefix,checkTag,'CheckDesc',num2str(i)]))];
        for j=1:size(resultDesc{i},1)
            retDesc{i}=[retDesc{i},ModelAdvisor.LineBreak,ModelAdvisor.Text(resultDesc{i}{j})];
        end
    end
