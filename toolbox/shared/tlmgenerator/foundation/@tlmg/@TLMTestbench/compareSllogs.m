function compareSllogs(this)









    gfm=globalfimath();
    savedgfm=gfm.copy();
    warnstate=warning;
    warning('off','fixed:fimath:configuringGlobalfimathToBeRemoved');
    gfm.MaxProductWordLength=65535;
    gfm.MaxSumWordLength=65535;

    logField=['this.OrigSllog.',this.OrigSllogName];
    lgobj=eval(logField);


    if(~isempty(this.TlmSllog))
        tlmsigs=fieldnames(this.TlmSllog.(this.TlmSllogName));
        for tlmsig=tlmsigs'

            curSig=tlmsig{:};
            if(isa(lgobj,'Simulink.ModelDataLogs'))
                slField=['this.OrigSllog.',this.SllogBasePath,'.',curSig,'.Data'];
            elseif(isa(lgobj,'Simulink.SimulationData.Dataset'))
                slField=['this.OrigSllog.',this.OrigSllogName,'.getElement(''',curSig,''').Values.Data'];
            end
            tlmField=['this.TlmSllog.',this.TlmSllogName,'.',curSig,'.Data'];
            slData=eval(slField);
            tlmData=eval(tlmField);

            flatSl=reshape(slData,prod(size(slData)),1);%#ok<PSIZE> numel not working with fi
            flatTlm=reshape(tlmData,prod(size(tlmData)),1);%#ok<PSIZE> numel not working with fi

            diffSig=flatSl-flatTlm;
            miscompares=find((flatSl~=flatTlm));


            if(any(miscompares))
                if(numel(miscompares)>20)
                    disp(['Found miscompares for signal ',curSig,' at indexes [',num2str(miscompares(1:20)'),' ...]. Here are the first 20.']);
                    endIdx=20;
                else
                    endIdx=numel(miscompares);
                    disp(['Found miscompares for signal ',curSig,' at indexes [',num2str(miscompares'),'].']);
                end

                arrayfun(@(x)(fprintf('orig = %+.16e, tlm = %+.16e, diff = %+.16e\n',...
                double(flatSl(x)),double(flatTlm(x)),double(diffSig(x)))),...
                miscompares(1:endIdx));

                disp('Generating plot...');
                h=figure();%#ok<NASGU>
                subplot(2,1,1);
                plot([1:length(flatSl)],flatSl,'b+:',...
                [1:length(flatTlm)],flatTlm,'go--');%#ok<NBRAK>
                title(['Data Comparison for Signal ',curSig]);
                legend('Original Simulink Data','TLM Response Data');
                subplot(2,1,2);
                plot([1:length(flatSl)],diffSig,'rx-');%#ok<NBRAK>
                title('Difference');

            else
                disp(['Data successfully compared for signal ',curSig,'.']);
            end

        end
    end


    globalfimath(savedgfm);
    warning(warnstate);
end
