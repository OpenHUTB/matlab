classdef Utils<handle
    methods(Static)

        function prettyPrint(o,hexPattern)





            narginchk(1,2);
            validType=isobject(o)|isstruct(o);

            if nargin<2
                hexPattern='';
            end

            if~validType||~isscalar(o)
                try
                    builtin('disp',o);
                    return
                catch
                    error('Input must be scalar MATLAB object or struct.')
                end
            end
            S=evalc('builtin(''disp'',o)');
            names=fieldnames(o);
            a=cellfun('length',names);
            fieldWidth=4+max(a);
            for i=1:length(names)
                n=names{i};
                try
                    val=o.(n);
                catch

                end

                if isscalar(val)&&~isempty(hexPattern)
                    asHex=true;
                    index=regexp(lower(n),hexPattern);
                    if isempty(index)
                        asHex=false;
                    end

                    if asHex&&isa(val,'uint32')
                        leader=sprintf(['%',num2str(fieldWidth),'s: '],n);
                        s=['0x',dec2hex(val)];
                        S=regexprep(S,[leader,'.*\n??'],[leader,s],'dotexceptnewline');
                    end
                end

                if isobject(val)||isstruct(val)
                    if isa(val,'embedded.fi')
                        s=sprintf('%s\n',num2str(val));
                    else
                        s0=evalc('disp(val)');
                        s1=evalc('dnnfpga.dagCompile.Utils.prettyPrint(val, hexPattern)');
                        if length(s1)<=length(s0)
                            s=s1;
                        else
                            s=s0;
                        end
                    end

                    if isscalar(regexp(s,'[\r\n]+'))

                        if isstruct(val)
                            s=strtrim(regexprep(s,'\s+',' '));
                        else
                            s=strtrim(s);
                        end

                        leader=sprintf(['%',num2str(fieldWidth),'s: '],n);

                        S=regexprep(S,[leader,'.*\n??'],[leader,s],'dotexceptnewline');
                    end
                end
            end
            disp(S(1:end-1))
        end



        function[enableAdder,enableFC,enableConv,enableSegmentation]...
            =calculateEnables(network)
            import dnnfpga.dagCompile.*

            enableAdder=false;
            enableConv=false;
            enableFC=false;
            enableSegmentation=false;

            for layer=network.Layers'
                if Layers.isAdd(layer)
                    enableAdder=true;
                end
                if Layers.isConv(layer)
                    enableConv=true;
                end
                if Layers.isFC(layer)
                    enableFC=true;
                end
                if Layers.isUnpool(layer)
                    enableConv=true;
                    enableSegmentation=true;
                end
                if Layers.isCustomLayer(layer)
                    enableAdder=true;
                end
                if dnnfpga.macros.Macros.isMacro(layer)
                    net=dnnfpga.macros.Macros.createNet(layer,0);
                    [eAdder,eFC,eConv,eSegmentation]=Utils.calculateEnables(net);
                    enableAdder=enableAdder||eAdder;
                    enableFC=enableFC||eFC;
                    enableConv=enableConv||eConv;
                    enableSegmentation=enableSegmentation||eSegmentation;
                end
            end

        end


        function[path]=findDotExecutable()




            path=[];
            if ispc







                prefixes={'C:\Program Files (x86)\','\\mathworks\hub\share\sbtools\external-apps\graphviz\'};
                for prefix=prefixes
                    results=dir([prefix{1},'*raph*iz*/**/bin/dot.exe']);
                    for result=flip(results)'
                        path=[result.folder,'\',result.name];
                        if exist(path,'file')==2
                            break;
                        end
                    end
                end
            elseif ismac

                paths={'/usr/bin/dot','/usr/local/bin/dot'};
                for i=1:numel(paths)
                    path=paths{i};
                    if exist(path,'file')==2
                        break;
                    end
                end
            elseif isunix

                [~,cmdout]=unix('dot -V');
                found=strfind(cmdout,'graphviz');
                if isempty(found)
                    path=[];
                else
                    path='dot';
                end
            else
                error('Your platform does not seem to be supported');
            end

            if(~isempty(path)&&exist(path,'file')==2)||(strcmp(path,'dot')&&isunix&&~ismac)

            else
                error("Unable to locate the dot execuatble file.");
            end
        end

        function v=cmpChars(a,b)
            a=convertStringsToChars(a);
            b=convertStringsToChars(b);
            if numel(a)~=numel(b)
                v=false;
                return;
            end
            v=all(a==b);
        end

        function isrnn=isRNN(net)
            networkInfo=dltargets.internal.NetworkInfo(net,[]);
            isrnn=dltargets.internal.sharedNetwork.checkNetworkForSequenceInput(net,networkInfo.InputLayers);
        end

        function issequential=isSequential(net)
            networkInfo=dltargets.internal.NetworkInfo(net,[]);
            issequential=dltargets.internal.sharedNetwork.checkNetworkForSequenceInput(net,networkInfo.InputLayers);
        end
    end
end
