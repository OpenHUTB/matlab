
function vmap_cEmitted=insertDSPBACompileScripts(this,fid,vmap_cEmitted)


    dspbaCodeGenPath=targetcodegen.alteradspbadriver.getDSPBACodeGenPath();
    if(~isempty(dspbaCodeGenPath))
        if(~vmap_cEmitted)
            fprintf(fid,'vmap -c\n');
            vmap_cEmitted=true;
        end
        mapAlteraStr=hdlprinttargetcodegenheaders(hdlsynthtoolenum.Quartus,this.getDUTLanguage,true);
        dspbaLibStr=dspbaLibCompilationStr('work');
        fprintf(fid,['\nset curDir [pwd]\n',mapAlteraStr,dspbaLibStr,'\n']);
        for i=1:length(dspbaCodeGenPath)
            libName=dspbaCodeGenPath(i).codeGenPath;

            codegenResults=targetcodegen.alteradspbadriver.getDSPBACodeGenResults();
            islandResults=codegenResults.Islands(strcmp({codegenResults.Islands.SimulinkPath},dspbaCodeGenPath(i).simulinkPath));
            fileList=targetcodegen.alteradspbadriver.getDSPBAHDLFiles(islandResults,true,true);

            vcomStr=vcom(this,libName,fileList);
            mapAlteraStr=hdlprinttargetcodegenheaders(hdlsynthtoolenum.Quartus,this.getDUTLanguage,true,true,libName);
            dspbaLibStr=dspbaLibCompilationStr(libName);
            fprintf(fid,...
            ['cd ',codegenResults.RTLPath,'\n',...
            mapAlteraStr,...
            dspbaLibStr,'\n',...
            vcomStr,...
            'cd ','$curDir\n',...
            'vmap ',libName,' ',codegenResults.RTLPath,'/',libName,'\n',...
            ]);
        end
    end
end

function s=dspbaLibCompilationStr(lib)
    s='';
    s=sprintf('%svlib %s\n',s,lib);
    s=sprintf('%svmap %s %s\n',s,lib,lib);
    s=sprintf('%svcom -work %s -2002 -explicit $path_to_quartus/dspba/backend/Libraries/vhdl/base/dspba_library_package.vhd\n',s,lib);
    s=sprintf('%svcom -work %s -2002 -explicit $path_to_quartus/dspba/backend/Libraries/vhdl/base/dspba_library.vhd\n',s,lib);
end

function tclStr=vcom(this,libName,fileList)


    tclStr='';
    lang=this.getDUTLanguage;
    tclStr=sprintf('%svlib %s\n',tclStr,libName);
    flags=['-work ',libName,' -nowarn 1 ',this.SimulatorFlags];
    if(strcmpi(lang,'vhdl'))
        compCmd=this.HdlCompileVHDLCmd;
    else
        compCmd=this.HdlCompileVerilogCmd;
        [pathToAltera,~]=targetcodegen.alteradriver.getPathToAltera('verilog');
        tclStr=[tclStr,sprintf(compCmd,flags,[pathToAltera,'/verilog/src/glbl.v'])];
    end
    for i=1:length(fileList)

        tclStr=[tclStr,sprintf(compCmd,flags,fileList{i})];%#ok<*AGROW>
    end
end

