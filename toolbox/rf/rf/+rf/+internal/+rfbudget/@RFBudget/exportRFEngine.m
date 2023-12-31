function[ckt,success]=exportRFEngine(obj,varargin)




    narginchk(1,Inf)
    p=inputParser;
    p.CaseSensitive=false;
    p.addParameter('Analyze',true);
    p.addParameter('Noise',false);
    p.addParameter('InputFrequencies',[]);
    p.addParameter('Tones',[]);
    p.addParameter('Harmonics',[]);
    p.addParameter('Length',numel(obj.Elements));
    p.addParameter('FreqIdx',[]);
    p.addParameter('Editor',false);
    p.addParameter('Circuit',[])
    p.parse(varargin{:});
    args=p.Results;


    thOpts={};
    if isscalar(args.Harmonics)&&isvector(args.Tones)
        args.Harmonics=args.Harmonics*ones(size(args.Tones));
    end
    for k=1:length(args.Tones)
        thOpts{end+1}=sprintf('%.15g',args.Tones(k));%#ok<AGROW>
        thOpts{end+1}=sprintf('%.15g',args.Harmonics(k));%#ok<AGROW>
    end

    if isempty(args.Circuit)||...
        ~isequal(args.Circuit.HB.Tones,args.Tones)||...
        ~isequal(args.Circuit.HB.NumHarmonics,args.Harmonics)

        ckt=rf.internal.rfengine.Circuit;
        ckt.Analyses{end+1}=feval(ckt.AnalysisMap('HB'),ckt,thOpts{:});

        lines{1,1}='* generated by exportRFEngine';

        inputPwr_dBm=obj.AvailableInputPower;
        inputPwr=10^((inputPwr_dBm-30)/10);

        vin=2*sqrt(50*inputPwr);

        freq=args.InputFrequencies;
        bottom='0';
        for k=1:length(freq)
            if k<length(freq)
                top=sprintf('mid%d',k);
            else
                top='in';
            end
            if freq(k)==0
                lines{end+1,1}=sprintf('vin%d %s %s sin(0 %.15g %.15g 0 0 90)',...
                k,top,bottom,vin/2,freq(k));%#ok<AGROW>
            else
                lines{end+1,1}=sprintf('vin%d %s %s sin(0 %.15g %.15g 0 0 90)',...
                k,top,bottom,vin,freq(k));%#ok<AGROW>
            end
            toks=split(lines{end})';
            rf.internal.rfengine.elements.Vsin.add(ckt,toks{:})
            bottom=top;
        end

        lines{end+1,1}=sprintf('rin in 1 50');
        toks=split(lines{end})';
        rf.internal.rfengine.elements.R.add(ckt,toks{:})

        if args.Noise
            in=4*rf.physconst('Boltzmann')*290/50;
            lines{end+1,1}=sprintf('aiin in 1 %.15g',in);
            toks=split(lines{end})';
            rf.internal.rfengine.elements.AI.add(ckt,toks{:})
        end

        for j=1:args.Length
            elem=obj.Elements(j);
            if isa(elem,'amplifier')||isa(elem,'modulator')||isa(elem,'mixerIMT')
                elemLines=exportRFEngineElement(elem,j,j,j+1,ckt,args.Noise,args.FreqIdx);
            else
                elemLines=exportRFEngineElement(elem,j,j,j+1,ckt,args.Noise);
            end
            lines(end+1:end+length(elemLines),1)=elemLines;
        end

        lines{end+1,1}=sprintf('rout %d 0 50',j+1);
        toks=split(lines{end})';
        rf.internal.rfengine.elements.R.add(ckt,toks{:})
    else


        ckt=args.Circuit;

        len=args.Length;
        oldLastNodeStr=sprintf('%d',len);
        ckt.NodeCountMap(oldLastNodeStr)=ckt.NodeCountMap(oldLastNodeStr)-1;

        elem=obj.Elements(len);
        if isa(elem,'amplifier')||isa(elem,'modulator')||isa(elem,'mixerIMT')
            elemLines=exportRFEngineElement(elem,len,len,len+1,ckt,args.Noise,args.FreqIdx);
        else
            elemLines=exportRFEngineElement(elem,len,len,len+1,ckt,args.Noise);
        end

        lines=ckt.Flattened(1:end-2);
        lines(end+1:end+length(elemLines),1)=elemLines;
        lines{end+1,1}=sprintf('rout %d 0 50',len+1);

        newLastNodeStr=sprintf('%d',len+1);
        ckt.NodeCountMap(newLastNodeStr)=ckt.NodeCountMap(newLastNodeStr)+1;

        j=find(strcmpi(ckt.R.Label,'rout'));
        ckt.R.Resistance=...
        [ckt.R.Resistance(1:j-1),ckt.R.Resistance(j+1:end),ckt.R.Resistance(j)];
        ckt.R.Label=[ckt.R.Label(1:j-1),ckt.R.Label(j+1:end),ckt.R.Label(j)];
        ckt.R.NodeNames=...
        [ckt.R.NodeNames(:,1:j-1),ckt.R.NodeNames(:,j+1:end),ckt.R.NodeNames(:,j)];
        ckt.R.NodeNames{1,end}=newLastNodeStr;
    end

    toks=join(thOpts);
    lines{end+1,1}=sprintf('.hb %s',toks{1});

    ckt.Flattened=lines;

    if args.Editor
        sw=StringWriter;
        for k=1:length(lines)
            addcr(sw,lines{k});
        end
        matlab.desktop.editor.newDocument(sw.string);
    end

    if args.Analyze
        params=rf.internal.rfengine.analyses.parameters;
        prepareForAnalysis(ckt)
        [~,success]=Execute(ckt.HB,params);
    else
        success=false;
    end
end
