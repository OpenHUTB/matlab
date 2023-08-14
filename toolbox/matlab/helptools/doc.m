function doc(varargin)
    %  DOC 帮助浏览器中的参考页
    %  
    %     DOC 打开帮助浏览器。如果帮助浏览器已打开但未显示，
    %       则 doc 将使其显示在前台并打开一个新的选项卡。
    %   
    %     DOC FUNCTIONNAME displays the reference page for FUNCTIONNAME in
    %     the Help browser. FUNCTIONNAME can be a function or block in an
    %     installed MathWorks product.
    %   
    %     DOC METHODNAME displays the reference page for the method
    %     METHODNAME. You may need to run DOC CLASSNAME and use links on the
    %     CLASSNAME reference page to view the METHODNAME reference page.
    %   
    %     DOC CLASSNAME displays the reference page for the class CLASSNAME.
    %     You may need to qualify CLASSNAME by including its package: DOC
    %     PACKAGENAME.CLASSNAME.
    %   
    %     DOC CLASSNAME.METHODNAME displays the reference page for the method
    %     METHODNAME in the class CLASSNAME. You may need to qualify
    %     CLASSNAME by including its package: DOC PACKAGENAME.CLASSNAME.
    %   
    %     DOC FOLDERNAME/FUNCTIONNAME displays the reference page for the
    %     FUNCTIONNAME that exists in FOLDERNAME. Use this syntax to display the
    %     reference page for an overloaded function.
    %   
    %     DOC USERCREATEDCLASSNAME displays the help comments from the
    %     user-created class definition file, UserCreatedClassName.m, in an
    %     HTML format in the Help browser. UserCreatedClassName.m must have a
    %     help comment following the classdef UserCreatedClassName statement
    %     or following the constructor method for UserCreatedClassName. To
    %     directly view the help for any method, property, or event of
    %     UserCreatedClassName, use dot notation, as in DOC
    %     USERCREATEDCLASSNAME.METHODNAME. 
    %
    %     Examples:
    %        doc abs
    %        doc fixedpoint/abs  % ABS function in the Fixed-Point Designer Product
    %        doc handle.findobj  % FINDOBJ method in the HANDLE class
    %        doc handle          % HANDLE class
    %        doc containers.Map  % Map class in the containers method
    %        doc sads            % User-created class, sads
    %        doc sads.steer      % steer method in the user-created class, sads

    %   Copyright 1984-2022 The MathWorks, Inc.
    
    % 获得当前工作空间已经存在的变量
    % 在指定的工作区 caller 中计算 MATLAB 表达式
    % caller：被调函数的工作区，从主调函数基本工作区获取变量值（即调用doc的地方）
    % matlab\toolbox\matlab\general\+matlab\+internal\+language\+introspective\getWorkspaceVars.m
    wsVariables = evalin('caller', 'matlab.internal.language.introspective.getWorkspaceVars');
    topics = matlab.internal.doc.reference.ReferenceTopicInput.parseTopicInputs(varargin, wsVariables);
    % Resolve any remaining variables. This has to be done in doc.m rather
    % than a helper function because it uses inputname.
    for i = 1:length(topics)
        if topics(i).VariableIndex
            topics(i).VariableName = inputname(topics(i).VariableIndex);
        end
    end

    [docPage, displayText, primitive] = matlab.internal.doc.reference.getReferencePage(topics);
    launcher = [];
    if isempty(docPage)
        if ~isempty(displayText) 
            launcher = matlab.internal.doc.ui.DocPageLauncher.getLauncherForHtmlText(displayText);
        elseif primitive
            % topics will always be a scalar in this case.
            varChar = char(topics.VariableName);
            topicChar = char(topics.Topic);
            disp(matlab.internal.help.getInstanceIsa(varChar, topicChar));
            return;
        else
            docPage = matlab.internal.doc.url.MwDocPage;
            docPage.RelativePath = "nofunc.html";
        end
    end
    
    if ~isempty(docPage)
        launcher = matlab.internal.doc.ui.DocPageLauncher.getLauncherForDocPage(docPage);
    end

    if ~isempty(launcher)
        launcher.openDocPage;
    end
end
