function s=getStylesheet(o,s,varargin)















    if nargin<2
        s=o.getStylesheetID;
    else
        if rptgen.use_java
            outputFormat='com.mathworks.toolbox.rptgencore.output.OutputFormat';
        else
            outputFormat='rptgen.internal.output.OutputFormat';
        end
        if isa(s,outputFormat)

            s=o.getStylesheetID(s);
        end
    end

    if rptgen.use_java
        sMaker='com.mathworks.toolbox.rptgencore.tools.StylesheetMaker';
    else
        sMaker='mlreportgen.re.internal.db.StylesheetMaker';
    end

    if isempty(s)
        return;
    elseif ischar(s)
        if exist(s,'file')==2

            if rptgen.use_java
                sm=javaObject(sMaker,[],s);
            else
                sm=mlreportgen.re.internal.db.StylesheetMaker([],s);
            end

            s=sm.makeXSLTSource;

        else
            if rptgen.use_java
                ext=com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.FILE_EXT_SS;
            else
                ext=mlreportgen.re.internal.db.StylesheetMaker.FILE_EXT_SS;
            end
            ssFile=rptgen.findfile([s,char(ext)]);
            if isempty(ssFile)
                ssFile=which('rptstylesheets.xml','-all');
            else



                s=[];
            end

            if rptgen.use_java
                sm=javaObject(sMaker,s,ssFile);
            else
                sm=mlreportgen.re.internal.db.StylesheetMaker(s,ssFile);
            end

            if isempty(sm.getID)

                s=[];

            else
                for i=1:2:length(varargin)-1
                    try

                        if isempty(sm.getParameter(varargin{i}))
                            sm.setParameter(varargin{i},varargin{i+1});
                        end
                    catch ex
                        warning(message('rptgen:rx_db_output:setStylesheetParam',ex.message));
                    end
                end

                if strcmpi(o.Format,'latex')

                    tEl=sm.addTemplate('rptgen:importpost',[],[]);
                    tEl.setAttribute('xmlns:rptgen','http://www.mathworks.com/namespace/rptgen/import/v1');
                    tEl=sm.addTemplate('mwsh:code',[],[]);
                    tEl.setAttribute('xmlns:mwsh','http://www.mathworks.com/namespace/mcode/v1/syntaxhighlight.dtd');
                end

                if strcmpi(o.Format,'pdf-fop')
                    lfm=rptgen.utils.LanguageFontMap.getInstance();
                    rg=rptgen.appdata_rg;
                    locale=rg.Language;
                    if~isempty(locale)
                        bodyFont=getFontName(lfm,'body',locale);
                        if isempty(sm.getParameter('body.font.family'))&&...
                            ~isempty(bodyFont)
                            sm.setParameter('body.font.family',bodyFont);
                        end
                        monoFont=getFontName(lfm,'monospace',locale);
                        if isempty(sm.getParameter('monospace.font.family'))&&...
                            ~isempty(monoFont)
                            sm.setParameter('monospace.font.family',monoFont);
                        end
                        sansFont=getFontName(lfm,'sans',locale);
                        if isempty(sm.getParameter('sans.font.family'))&&...
                            ~isempty(sansFont)
                            sm.setParameter('sans.font.family',sansFont);
                        end
                        titleFont=getFontName(lfm,'title',locale);
                        if isempty(sm.getParameter('title.font.family'))&&...
                            ~isempty(titleFont)
                            sm.setParameter('title.font.family',titleFont);
                        end
                    end
                end

                s=sm.makeXSLTSource;
            end
        end
    elseif isa(s,sMaker)
        s=s.makeXSLTSource;
    elseif isa(s,'javax.xml.transform.Source')

    elseif isa(s,'RptgenML.StylesheetEditor')
        s=o.getStylesheet(s.JavaHandle,varargin{:});
    else
        s=[];
    end




