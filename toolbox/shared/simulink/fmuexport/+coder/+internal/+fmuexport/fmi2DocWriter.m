


classdef(Hidden=true)fmi2DocWriter<coder.internal.fmuexport.CodeWriter
    properties(Access=private)
ModelInfoUtils
    end


    methods(Access=public)
        function this=fmi2DocWriter(modelInfoUtils,fileName)
            this=this@coder.internal.fmuexport.CodeWriter(fileName);
            this.ModelInfoUtils=modelInfoUtils;
            this.writeDocBody;
        end
    end
    methods(Access=private)
        function writeDocBody(this)
            content=this.writeHead;
            content=[content;this.writeBody];
            cellfun(@(aLine)this.writeString(aLine),content);
        end
        function content=writeHead(~)
            content="<!DOCTYPE html>";
        end
        function content=writeBody(this)
            content=this.writeHTML;
        end
        function content=writeHTML(this)
            content=sprintf("<html>\n<body>");
            content=[content;this.writeIntroSummary];
            content=[content;this.writeSourceCodeDistributionInfo];
            content=[content;sprintf("</body>\n</html>")];
        end
        function content=writeIntroSummary(this)
            ModelName=this.writeTag('b',this.ModelInfoUtils.CodeInfo.Name);
            content=this.writeTag('p',sprintf("This FMU was generated for %s through Simulink Compiler&reg;.",ModelName));
        end
        function content=writeSourceCodeDistributionInfo(this)
            content=this.writeTag('h2',"Source code distribution");
            content=[content;this.writeTag('p',...
            "The source code of this FMU is located in sources/ directory. The files listed below are required:")];

            SourceFileTags=cellfun(@(x)sprintf("%s<br/>",x),this.ModelInfoUtils.SourceFileList);
            content=[content;this.writeTag('p',strjoin(SourceFileTags,'\n'))];
            content=[content;this.writeTag('p',...
            "To build standalone executables or static library, compile FMU source code with standard FMI 2.0 header files, downloadable from <a href=""http://www.fmi-standard.org/downloads/"">www.fmi-standard.org/downloads/</a>.")];

            content=[content;this.writeTag('h3',"Instructions for recompiling FMU dynamic library from source")];
            content=[content;
            this.writeTag('p',...
            "To generate FMU dynamic library from source file, use a target specific variant of FMI 2.0 header files. You can download the standard header files and replace ""#if !defined(FMI2_FUNCTION_PREFIX)"" line in fmi2Functions.h with ""#if 1"". For more infomation, see <a href=""http://www.github.com/modelica/fmi-standard/issues/420"">discussion</a> on FMI project page.");
            this.writeTag('p',...
            "After dynamic library is generated, copy the file into a target specific directory (for example: linux64, win64 or darwin64) under binaries/ in FMU zip package.")];
            content=[content;this.writeBuildCommandForLinux];
            content=[content;this.writeBuildCommandForWindows];
            content=[content;this.writeBuildCommandForMACI];
        end
        function content=writeBuildCommandForLinux(this)
            content=this.writeTag('h4',"Build command for Linux using gcc");

            content=[content;this.writeTag('p',...
            sprintf("gcc -I&lt;directoryWithFMUHeader&gt; -I&lt;directoryWithSourceCode&gt; -c &lt;source files in model description.xml&gt; -fPIC"))];

            content=[content;this.writeTag('p',...
            sprintf("gcc -shared -o &lt;filename.so&gt; &lt;generated object files&gt; -lm"))];


            content=[content;this.writeTag('p',...
            sprintf("For example: gcc -I/local/shared/fmuexport/fmi2/ -I/tmp/FMUExport/%s/sources/ -c %s -fPIC",...
            this.ModelInfoUtils.CodeInfo.Name,...
            strjoin(this.ModelInfoUtils.SourceFileList)))];

            objFileNameCell=getObjectFileNames(this.ModelInfoUtils.SourceFileList,'.o');

            content=[content;this.writeTag('p',...
            sprintf("gcc -shared -o %s.so %s -lm",...
            this.ModelInfoUtils.CodeInfo.Name,...
            strjoin(objFileNameCell)))];
        end
        function content=writeBuildCommandForWindows(this)
            content=this.writeTag('h4',"Build command for Windows using MSVC x64 Native Tools Command Prompt");
            backSlash='&#92;';


            content=[content;this.writeTag('p',...
            sprintf("CL -I&lt;directoryWithFMUHeader&gt; -I&lt;directoryWithSourceCode&gt; &lt;source files in model description.xml&gt; -nologo -GS -c"))];


            content=[content;this.writeTag('p',...
            sprintf("LINK -DLL -OUT:&lt;filename.dll&gt; &lt;generated object files&gt; -MACHINE:X64"))];


            content=[content;
            this.writeTag('p',...
            sprintf("For example: CL -IC:%sfmuexport%sfmi2%s -IC:%stemp%sFMUExport%s%s%ssources %s -nologo -GS -c",...
            backSlash,...
            backSlash,...
            backSlash,...
            backSlash,...
            backSlash,...
            backSlash,...
            this.ModelInfoUtils.CodeInfo.Name,...
            backSlash,...
            strjoin(this.ModelInfoUtils.SourceFileList)))];

            objFileNameCell=getObjectFileNames(this.ModelInfoUtils.SourceFileList,'.obj');

            content=[content;
            this.writeTag('p',sprintf("LINK -DLL -OUT:%s.dll %s -MACHINE:X64",...
            this.ModelInfoUtils.CodeInfo.Name,...
            strjoin(objFileNameCell)))];
        end
        function content=writeBuildCommandForMACI(this)
            content=this.writeTag('h4',"Build command for macOS using gcc");


            content=[content;this.writeTag('p',...
            sprintf("gcc -I&lt;directoryWithFMUHeader&gt; -I&lt;directoryWithSourceCode&gt; -c &lt;source files in model description.xml&gt; -fPIC"))];


            content=[content;this.writeTag('p',...
            sprintf("gcc -shared -o &lt;filename.dylib&gt; &lt;generated object files&gt; -lm"))];


            content=[content;this.writeTag('p',...
            sprintf("For example: gcc -I/local/shared/fmuexport/fmi2/ -I/tmp/FMUExport/%s/sources/ -c %s -fPIC",...
            this.ModelInfoUtils.CodeInfo.Name,...
            strjoin(this.ModelInfoUtils.SourceFileList)))];

            objFileNameCell=getObjectFileNames(this.ModelInfoUtils.SourceFileList,'.o');

            content=[content;this.writeTag('p',...
            sprintf("gcc -shared -o %s.dylib %s -lm",...
            this.ModelInfoUtils.CodeInfo.Name,...
            strjoin(objFileNameCell)))];
        end

        function content=writeTag(~,tag,str)
            content=sprintf("<%s>%s</%s>",tag,str,tag);
        end
    end
end
function objFileNameCell=getObjectFileNames(cFileNamesWithExt,ext)
    [~,cFileNames,~]=cellfun(@(x)fileparts(x),cFileNamesWithExt,'un',0);
    objFileNameCell=cellfun(@(x)strcat(x,ext),cFileNames,'un',0);
end
