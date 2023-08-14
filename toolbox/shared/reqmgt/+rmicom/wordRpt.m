function out=wordRpt(method)



    persistent our_word;

    out=[];
    switch(lower(method))

    case 'setup'




        our_word=[];

        while true
            try
                dummy=actxGetRunningServer('word.application');%#ok
                dummy=[];%#ok - this avoids stored reference in 'ans'



                selection=questdlg({...
                getString(message('Slvnv:reqmgt:com_word_check_app:WordAppearsToBeRunning')),...
                '',...
                getString(message('Slvnv:reqmgt:com_word_check_app:IfYouContinue'))},...
                getString(message('Slvnv:reqmgt:com_word_check_app:MicrosoftWordRunning')),...
                'Retry','Continue','Cancel','Retry');

                if isempty(selection)
                    selection='Retry';
                end
                switch selection,
                case 'Retry',
                    continue;
                case 'Cancel',
                    out=0;
                    break;
                case 'Continue'
                    out=1;
                    break;
                end
            catch Mex %#ok

                out=1;
                break;
            end
        end


    case 'init'






        if~isempty(our_word)
            try
                our_word.Close();
            catch Mex %#ok
            end
            our_word=[];
        end




        throw=false;
        try
            dummy=actxGetRunningServer('word.application');%#ok
            dummy=[];%#ok - this avoids stored reference in 'ans'

            rmi.mdlAdvState('word',-1);
            throw=true;
        catch Mex %#ok

            our_word=actxserver('word.application');
            our_word.Visible=1;

            rmi.mdlAdvState('word',1);
            out=our_word;
        end
        if throw
            error(message('Slvnv:reqmgt:com_word_check_app:WordSessionDetected'));
        end



    case 'get'


        if isempty(our_word)
            our_word=actxserver('word.application');
            our_word.Visible=1;
        else
            try
                if~our_word.Visible
                    our_word.Visible=1;
                end
            catch Mex %#ok
                our_word=actxserver('word.application');
                our_word.Visible=1;
            end
        end
        out=our_word;


    case 'destroy'



        if~isempty(our_word)

            try
                our_word.Quit;
            catch Mex %#ok<NASGU>
            end
            pause(0.5);










            our_word=[];
        end
    end
end



