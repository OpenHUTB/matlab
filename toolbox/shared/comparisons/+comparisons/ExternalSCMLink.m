

























classdef ExternalSCMLink<handle

    properties(GetAccess=public,Constant)
        DiffExecutablePath=comparisons.ExternalSCMLink.getDiffPath();
        MergeExecutablePath=comparisons.ExternalSCMLink.getMergePath();
        AutoMergeExecutablePath=comparisons.ExternalSCMLink.getAutoMergePath();
    end


    methods(Access=private)
        function obj=ExternalSCMLink()

        end
    end


    methods(Access=public,Static)












        function varargout=enable()
            oldValue=comparisons.ExternalSCMLink.setPref(true);
            if(nargout==1)
                varargout{1}=oldValue;
            end
        end











        function varargout=disable()
            oldValue=comparisons.ExternalSCMLink.setPref(false);
            if(nargout==1)
                varargout{1}=oldValue;
            end
        end













        function setup()

            comparisons.ExternalSCMLink.enable();

            if(nargout==0)
                prefDesc=char(com.mathworks.comparisons.gui.preferences.DiffLinkPanel.getPrefDescription());

                msg=message('comparisons:comparisons:LinkSetupDescription',...
                prefDesc,...
                comparisons.ExternalSCMLink.DiffExecutablePath,...
                comparisons.ExternalSCMLink.MergeExecutablePath,...
                comparisons.ExternalSCMLink.AutoMergeExecutablePath);
                disp(msg.getString());
            end

        end


        function setupGitConfig()
            comparisons.ExternalSCMLink.setupGitAutoMergeDriver();
            comparisons.ExternalSCMLink.setupGitMergeTool();
            comparisons.ExternalSCMLink.setupGitDiffTool();
        end

        function setupGitAutoMergeDriver()
            comparisons.ExternalSCMLink.writeConfigEntry(...
            "merge.mlAutoMerge.driver",...
            comparisons.ExternalSCMLink.AutoMergeExecutablePath,...
            "%O %A %B %A");
        end

        function setupGitMergeTool()
            comparisons.ExternalSCMLink.writeConfigEntry(...
            "mergetool.mlMerge.cmd",...
            comparisons.ExternalSCMLink.MergeExecutablePath,...
            "$BASE $LOCAL $REMOTE $MERGED");
        end

        function setupGitDiffTool()
            comparisons.ExternalSCMLink.writeConfigEntry(...
            "difftool.mlDiff.cmd",...
            comparisons.ExternalSCMLink.DiffExecutablePath,...
            "$LOCAL $REMOTE");
        end
    end

    methods(Access=private,Static)
        function writeConfigEntry(entryName,exeName,exeArgs)
            config=matlab.internal.cmlink.git.Config();
            globalConfigFilePath=config.globalFilePath();

            newValue=""""+strrep(exeName,'\','/')+""" "+exeArgs;

            if~config.hasValue(entryName)
                config.setValue(entryName,newValue);
                msg=message('comparisons:comparisons:GitConfigSetupDescription',...
                entryName,globalConfigFilePath,config.getValue(entryName));
                disp(msg.getString());
            else
                origDriver=config.getValue(entryName);
                config.setValue(entryName,newValue);
                msg=message('comparisons:comparisons:GitConfigOverwriteDescription',...
                entryName,globalConfigFilePath,config.getValue(entryName),origDriver);
                disp(msg.getString());
            end
        end

        function oldValue=setPref(value)
            prefManager=com.mathworks.comparisons.prefs.ComparisonPreferenceManager.getInstance();
            pref=com.mathworks.comparisons.prefs.DiffLinkAutoStartPref.getInstance();
            oldValue=prefManager.getValue(pref);
            prefManager.setValue(pref,value);
        end

        function diffPath=getDiffPath()
            if ispc
                diffName='mlDiff.exe';
            else
                diffName='mlDiff';
            end

            diffPath=comparisons.ExternalSCMLink.getExecutablePath(diffName);
        end

        function mergePath=getMergePath()
            if ispc
                mergeName='mlMerge.exe';
            else
                mergeName='mlMerge';
            end
            mergePath=comparisons.ExternalSCMLink.getExecutablePath(mergeName);
        end

        function mergePath=getAutoMergePath()
            if ispc
                mergeName='mlAutoMerge.bat';
            else
                mergeName='mlAutoMerge';
            end
            mergePath=comparisons.ExternalSCMLink.getExecutablePath(mergeName);
        end

        function exePath=getExecutablePath(exeName)
            arch=computer('arch');
            exePath=fullfile(matlabroot,'bin',arch,exeName);
        end

    end

end
