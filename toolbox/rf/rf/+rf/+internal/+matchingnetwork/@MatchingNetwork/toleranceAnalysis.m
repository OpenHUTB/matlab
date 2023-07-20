





function h=toleranceAnalysis(obj,tolerances,frequencyList,circuitIndices)





    if(nargin<4||isempty(circuitIndices))
        circuitIndices=1:length(obj.SortedCkts);
    end
    if(~isnumeric(circuitIndices))

        circuitIndices=convertStringsToChars(circuitIndices);
        validateattributes(circuitIndices,{'cell','char'},{'vector'});
        if(ischar(circuitIndices))
            circuitIndices={circuitIndices};
        end
    end

    if(~isnumeric(circuitIndices))
        [~,~,circuitIndices]=obj.cktNamesToIndices(circuitIndices);
    end
    validateattributes(circuitIndices,{'numeric'},{'vector','<=',length(obj.SortedCkts),'real','finite','nonnan','positive'});


    if(nargin<3||isempty(frequencyList))
        frequencyList=obj.constructFrequencyList();
    end
    validateattributes(frequencyList,{'numeric'},{'vector','real','finite','nonnan','positive','nondecreasing'});



    matchCktCpy=obj.exportCircuits(circuitIndices);
    maxComponents=max(cellfun(@length,{matchCktCpy.Elements}));
    if(nargin<2||isempty(tolerances))
        tolerances=0.05;
    end
    validateattributes(tolerances,{'numeric'},{'vector','real','finite','nonnan','nonnegative','<',1});
    if(length(tolerances)==1)

        tolerances=tolerances*ones(1,maxComponents);
    end
    if(length(tolerances)<maxComponents)
        tolerances(end+1:maxComponents)=0;
    end


    h=cell(1,length(circuitIndices));

    [~,srcZ]=obj.interpretImpedanceData(obj.SourceImpedanceData,obj.SourceDataType,frequencyList);
    [~,loadZ]=obj.interpretImpedanceData(obj.LoadImpedanceData,obj.LoadDataType,frequencyList);


    [scaledFrequencyList,frequencyScaleFactor,freqPrefix]=engunits(frequencyList);


    evalparams=obj.getEvaluationParameters();










    for m=1:length(matchCktCpy)
        figure;hold on;


        cpyElements=matchCktCpy(m).Elements;
        componentTypes='R'*arrayfun(@(x)(isa(x,'resistor')),cpyElements);
        componentTypes=componentTypes+'C'*arrayfun(@(x)(isa(x,'capacitor')),cpyElements);
        componentTypes=componentTypes+'L'*arrayfun(@(x)(isa(x,'inductor')),cpyElements);
        if(length(componentTypes)<maxComponents)
            componentTypes(end+1:maxComponents)=0;
        end


        numComponents=length(componentTypes);
        componentOrigVals=zeros(1,numComponents);
        for j=1:numComponents
            if(componentTypes(j)=='R')
                componentOrigVals(j)=cpyElements(j).Resistance;
            elseif(componentTypes(j)=='C')
                componentOrigVals(j)=cpyElements(j).Capacitance;
            elseif(componentTypes(j)=='L')
                componentOrigVals(j)=cpyElements(j).Inductance;
            end
        end



        componentBounds(3,:)=componentOrigVals().*(1+tolerances);
        componentBounds(2,:)=componentOrigVals();
        componentBounds(1,:)=componentOrigVals().*(1-tolerances);


        for counter=0:3^numComponents-1
            indices=dec2base(counter,3,numComponents)-48+1;

            for k=1:length(indices)
                if(componentTypes(k)=='R')
                    matchCktCpy(m).Elements(k).Resistance=componentBounds(indices(k),k);
                elseif(componentTypes(k)=='L')
                    matchCktCpy(m).Elements(k).Inductance=componentBounds(indices(k),k);
                elseif(componentTypes(k)=='C')
                    matchCktCpy(m).Elements(k).Capacitance=componentBounds(indices(k),k);
                end
            end

            [gamma,efficiency]=obj.calcS11S21_circuitobj(srcZ,matchCktCpy(m),loadZ,frequencyList);
            h{m}=[h{m};plot(scaledFrequencyList,20*log10(abs(gamma)),'-b',scaledFrequencyList,10*log10(abs(efficiency)),'-r')];

        end
        for n=1:length(evalparams.Parameter)
            x=evalparams.Band{n}(1);
            w=evalparams.Band{n}(2)-evalparams.Band{n}(1);
            if(strcmp(evalparams.Comparison{n},'>'))
                hgt=1000;
                y=evalparams.Goal{n}-hgt;
            else
                y=evalparams.Goal{n};
                hgt=1000;
            end
            if(strcmp(evalparams.Parameter{n},'gammain'))



                color=[0,1,1,0.5];

            else



                color=[0,1,0,0.5];

            end
            r=rectangle('Position',[x*frequencyScaleFactor,y,w*frequencyScaleFactor,hgt]);
            r.FaceColor=color;
        end

        ylim([-20,0]);
        title(['Tolerance Analysis for Circuit ',num2str(circuitIndices(m)),' (''',obj.SortedCktsNames{circuitIndices(m)},''') '],'Interpreter','none');
        xlabel(['Frequency (',freqPrefix,'Hz)']);
        ylabel('Magnitude (dB)');
        legend({['Circuit ',num2str(circuitIndices(m)),': |gammain|, dB'],['Circuit ',num2str(circuitIndices(m)),': |Gt|, dB']});
        grid on;
        hold off;
    end



















end
