function[textAsShapes,textObjects]=needsTextAsShapes(exportHandle)














    textObjects=[];
    latexTextObjects=findall(exportHandle,...
    {'-isa','matlab.graphics.primitive.Text','-and','Interpreter','latex'},...
    '-or',{'-isa','matlab.graphics.illustration.Legend','-and','Interpreter','latex'},...
    '-or',{'TickLabelInterpreter','latex'},...
    'Visible','on');

    if(~isempty(latexTextObjects))
        textAsShapes=1;
        return;
    end



    textObjects=findall(exportHandle,'-isa','matlab.graphics.primitive.Text','Visible','on');


    allRulers=getAxesRulers(exportHandle);
    textObjects=getAxesTicksAsTextObjects(allRulers,textObjects);
    textAsShapes=checkTextObjects(textObjects);

    if(textAsShapes==0)

        textAsShapes=isNonZeroExponent(allRulers);
    end

    if(textAsShapes==0)



        textObjects=findobjinternal(exportHandle,'-Property','String','-and',...
        '-not','-isa','matlab.graphics.illustration.Legend','Visible','on');
        textAsShapes=checkTextObjects(textObjects);
    end
end

function textAsShapes=checkTextObjects(textObjects)

    textAsShapes=0;


    fontList=listfonts;




    if ispc
        fontList=[fontList;'MS Sans Serif'];
    end


    for idx=1:length(textObjects)


        theTextObj=textObjects(idx,1);
        text=get(theTextObj,'String');
        text=getCellArray(text);

        if(~isempty(text))
            supportedFont=isSupportedFont(theTextObj,fontList);
            charsNotSupported=anyCharsNotSupported(text);



            if(isa(theTextObj,'matlab.graphics.primitive.Text')||...
                isa(theTextObj,'matlab.graphics.primitive.world.Text'))&&...
                ~strcmp(theTextObj.Interpreter,'none')
                texCommands=containsTexCommands(text);
            else
                texCommands=0;
            end






            if~supportedFont||...
                any(charsNotSupported)||...
                any(texCommands)

                textAsShapes=1;
                return;
            end
        end
    end
end

function out=getCellArray(txt)




    if isempty(txt)
        out={};
    elseif ischar(txt)
        s=size(txt,1);
        out=cell(s,1);
        for idx=1:s
            out{idx}=txt(idx,:);
        end
    elseif iscellstr(txt)

        sizes=cellfun(@(x)size(x,1),txt,'UniformOutput',false);
        n=sum([sizes{:}]);
        out=cell(n,1);



        l=length(txt);
        index=1;
        for idx=1:l
            val=txt{idx};
            s=size(val,1);
            for j=1:s
                out{index}=val(j,:);
                index=index+1;
            end
        end
    else
        out={};
    end
end








function supportedFont=isSupportedFont(textObject,fontList)
    supportedFont=false;
    fontName='';


    if(isprop(textObject,'FontName'))
        fontName=get(textObject,'FontName');
    elseif(isprop(textObject,'Font'))
        fontObj=get(textObject,'Font');
        fontName=fontObj.Name;
    end

    if(~isempty(fontName))
        supportedFont=any(ismember(fontList,fontName));
    end
end






function charsNotSupported=anyCharsNotSupported(text)

    upperLimit=1024;

    unsupportedChars=cellfun(@(x)x>upperLimit,text,...
    'UniformOutput',false);
    charsNotSupported=cellfun(@any,unsupportedChars);
end




function texCommands=containsTexCommands(text)



    expr='^\\\w*|\\\w*';


    nonDisplayableTex={'\color',...
    '\fontsize',...
    '\fontname',...
    '\bf',...
    '\it',...
    '\rm',...
    '\sl',...
    '\newline'};
    singleChars={'\{','\}','\^','\\','\_'};


    for n=1:numel(singleChars)
        text=cellfun(@(x)strrep(x,singleChars{n},''),text,...
        'UniformOutput',false);
    end


    cellArraysWithTex=strtrim(regexp(text,expr,'match'));


    cellsWithTex=horzcat(cellArraysWithTex{:});


    texCommands=length(setdiff(cellsWithTex,nonDisplayableTex));
end

function allRulers=getAxesRulers(exportedHandle)


    cartesianAxes=findobjinternal(exportedHandle,'Type','axes','Visible','on');
    cartesianRulers=[];
    if~isempty(cartesianAxes)
        cartesianRulers=matlab.graphics.internal.printUtility.getAxesAllRulers(cartesianAxes,{'XAxis','YAxis','ZAxis'});
    end


    polarAxes=findobjinternal(exportedHandle,'Type','polaraxes','Visible','on');
    polarRulers=[];
    if~isempty(polarAxes)
        polarRulers=matlab.graphics.internal.printUtility.getAxesAllRulers(polarAxes,{'RAxis','ThetaAxis'});
    end


    allRulers=[cartesianRulers;polarRulers];
end

function textAsShape=isNonZeroExponent(allRulers)

    textAsShape=0;

    for i=1:length(allRulers)


        if isa(allRulers(i),'matlab.graphics.axis.decorator.NumericRuler')&&...
            allRulers(i).Exponent~=0
            textAsShape=1;
            break;
        end
    end
end


function textObjects=getAxesTicksAsTextObjects(allRulers,textObjects)

    for i=1:length(allRulers)
        textObjects=[textObjects;allRulers(i).TickLabelChild];
    end
end


