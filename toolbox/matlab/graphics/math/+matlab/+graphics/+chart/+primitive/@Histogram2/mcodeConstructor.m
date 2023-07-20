function mcodeConstructor(this,code)





    hParentMomento=up(get(code,'MomentoRef'));
    hPropertyList=get(hParentMomento,'PropertyObjects');

    if~isempty(hParentMomento)&&...
        isempty(findobj(hPropertyList,'Name','NextPlot'))

        hAxes=ancestor(this,'axes');
        if length(findobj(hAxes,'type','histogram2'))>1
            hParentCode=code.getParent();
            if~isempty(hParentCode)
                hPre=get(findobj(hParentCode,'-depth',1),...
                'PreConstructorFunctions');


                if all(cellfun(@(x)isempty(findobj(...
                    x,'Name','hold')),hPre))
                    hFunc=codegen.codefunction(...
                    'Name','hold','CodeRef',code);
                    addPreConstructorFunction(code,hFunc);


                    hAxesArg=codegen.codeargument(...
                    'Value',hAxes,'IsParameter',true);
                    addArgin(hFunc,hAxesArg);
                    hArg=codegen.codeargument('Value','on');
                    addArgin(hFunc,hArg);
                end
            end
        end
    end


    autobincountsmode=strcmp(this.BinCountsMode,'auto');
    if autobincountsmode
        if~strcmp(this.BinMethod,'manual')
            propsToAdd={'BinMethod'};
            propsToIgnore={'Data','XBinEdges','YBinEdges',...
            'BinWidth','NumBins','BinCounts'};
            if strcmp(this.XBinLimitsMode,'manual')
                propsToAdd=[propsToAdd,{'XBinLimits'}];
            else
                propsToIgnore=[propsToIgnore,{'XBinLimits'}];
            end
            if strcmp(this.YBinLimitsMode,'manual')
                propsToAdd=[propsToAdd,{'YBinLimits'}];
            else
                propsToIgnore=[propsToIgnore,{'YBinLimits'}];
            end
        else
            propsToIgnore={'Data','BinMethod','BinCounts'};
            if strcmp(this.XBinLimitsMode,'manual')
                if strcmp(this.BinWidth,'nonuniform')




                    propsToAdd={'XBinEdges','YBinEdges'};
                    propsToIgnore=[propsToIgnore,{'XBinLimits',...
                    'YBinLimits','NumBins','BinWidth'}];
                else
                    propsToAdd={'XBinLimits'};
                    propsToIgnore=[propsToIgnore,{'XBinEdges','YBinEdges'}];
                    if strcmp(this.YBinLimitsMode,'manual')
                        propsToAdd=[propsToAdd,{'YBinLimits'}];
                        if rem(this.YBinLimits(1),this.BinWidth(2))==0
                            propsToAdd=[propsToAdd,{'BinWidth'}];
                            propsToIgnore=[propsToIgnore,{'NumBins'}];
                        else
                            propsToAdd=[propsToAdd,{'NumBins'}];
                            propsToIgnore=[propsToIgnore,{'BinWidth'}];
                        end
                    else
                        propsToIgnore=[propsToIgnore,{'YBinLimits'}];
                        if rem(this.YBinLimits(1),this.BinWidth(2))==0
                            propsToAdd=[propsToAdd,{'BinWidth'}];
                            propsToIgnore=[propsToIgnore,{'NumBins'}];
                        else
                            propsToAdd=[propsToAdd,{'NumBins'}];
                            propsToIgnore=[propsToIgnore,{'BinWidth'}];
                        end
                    end

                end
            else
                propsToIgnore=[propsToIgnore,{'XBinLimits','XBinEdges'}];
                if strcmp(this.BinWidth,'nonuniform')




                    propsToAdd={'XBinEdges','YBinEdges'};
                    propsToIgnore=[propsToIgnore,{'YBinLimits',...
                    'NumBins','BinWidth'}];
                else
                    propsToIgnore=[propsToIgnore,{'YBinEdges'}];
                    if strcmp(this.YBinLimitsMode,'manual')
                        propsToAdd={'YBinLimits'};
                        if rem(this.XBinLimits(1),this.BinWidth(1))==0
                            propsToAdd=[propsToAdd,{'BinWidth'}];
                            propsToIgnore=[propsToIgnore,{'NumBins'}];
                        else
                            propsToAdd=[propsToAdd,{'NumBins'}];
                            propsToIgnore=[propsToIgnore,{'BinWidth'}];
                        end
                    else
                        propsToIgnore=[propsToIgnore,{'YBinLimits'}];
                        if rem(this.XBinLimits(1),this.BinWidth(1))==0&&...
                            rem(this.YBinLimits(1),this.BinWidth(2))==0
                            propsToAdd={'BinWidth'};
                            propsToIgnore=[propsToIgnore,{'NumBins'}];
                        else
                            propsToAdd={'NumBins'};
                            propsToIgnore=[propsToIgnore,{'BinWidth'}];
                        end
                    end

                end
            end
        end
    else
        propsToAdd={'BinCounts','XBinEdges','YBinEdges'};
        propsToIgnore={'Data','BinMethod','NumBins','BinWidth',...
        'XBinLimits','YBinLimits'};
    end

    setConstructorName(code,'histogram2');
    if autobincountsmode
        arg=codegen.codeargument('Name','xdata',...
        'IsParameter',true,'comment','histogram2 X data');
        addConstructorArgin(code,arg);
        arg=codegen.codeargument('Name','ydata',...
        'IsParameter',true,'comment','histogram2 Y data');
        addConstructorArgin(code,arg);
    end

    ignoreProperty(code,propsToIgnore);
    addProperty(code,propsToAdd);


    generateDefaultPropValueSyntax(code);
end