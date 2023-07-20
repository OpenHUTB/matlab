


classdef RuleHierarchy
    methods(Static,Access=public)
        function rules=getCategoryRules()

            catRules=containers.Map('KeyType','char','ValueType','char');
            rules={'1','1.1','1.1.1','1.1.2','1.1.3','1.1.4','1.1.5','1.1.6','1.2','1.2.1','1.3','1.3.1',...
            '1.3.2','1.4','1.4.1','1.4.3','1.4.4','1.5','1.5.1','1.6','1.6.1','1.6.2','1.6.3','2',...
            '2.1','2.1.1','2.1.10','2.1.2','2.1.3','2.1.4','2.1.5','2.1.6','2.1.7','2.1.8','2.1.9',...
            '2.10','2.10.1','2.10.2','2.10.3','2.10.4','2.10.5','2.10.6','2.10.7','2.10.8','2.11',...
            '2.11.1','2.11.2','2.11.3','2.11.4','2.11.5','2.2','2.2.1','2.2.2','2.2.3','2.3','2.3.1',...
            '2.3.2','2.3.3','2.3.4','2.3.5','2.3.6','2.4','2.4.1','2.5','2.5.1','2.5.2','2.6','2.6.1',...
            '2.6.2','2.7','2.7.1','2.7.2','2.7.3','2.7.4','2.8','2.8.1','2.8.2','2.8.3','2.8.4','2.8.5',...
            '2.9','2.9.1','2.9.2','2.9.3','3','3.1','3.1.2','3.1.3','3.1.4','3.1.5','3.1.6','3.2','3.2.2',...
            '3.2.3','3.2.4','3.3','3.3.1','3.3.2','3.3.3','3.3.6','3.5','3.5.2','3.5.3','3.5.6'};
            for itr=1:length(rules)
                catRules(rules{itr})=message(['hdlcommon:IndustryStandard:rule_',strrep(rules{itr},'.','_')]).getString();
            end

            rules=catRules;
        end



        function rules=getUnconditionalRules(target_lang,codingStdOptions)

            ucRules=containers.Map('KeyType','char','ValueType','char');
            Xmessage=@(x)message([x,'_',upper(target_lang)]).getString;
            Xmessage1=@(x,a)message([x,'_',upper(target_lang)],a).getString;


            ucRules('1.1.1.1')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_1_1');



            ucRules('1.1.1.2-3')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_1_2_3');
            ucRules('1.1.1.3vb')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_1_3vb');
            ucRules('1.1.1.4')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_1_4');
            ucRules('1.1.1.5')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_1_5');
            ucRules('1.1.1.6')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_1_6');
            ucRules('1.1.1.6v')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_1_6v');

            ucRules('1.1.1.9')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_1_9');
            ucRules('1.1.1.9d')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_1_9d');

            ucRules('1.1.1.10')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_1_10');
            ucRules('1.1.2.1b')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_2_1b');

            ucRules('1.1.4.1')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_4_1');
            ucRules('1.1.4.1vb')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_4_1vb');
            ucRules('1.1.4.4')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_4_4');
            ucRules('1.1.4.4v')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_4_4v');
            ucRules('1.1.4.9')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_4_9');
            ucRules('1.1.4.9v')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_4_9v');
            ucRules('1.1.5.2')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_5_2');
            ucRules('1.1.5.2a')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_5_2a');
            ucRules('1.1.6.1')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_6_1');
            ucRules('1.1.6.4')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_6_4');
            ucRules('1.2.1.1a')=Xmessage('hdlcommon:IndustryStandard:rule_1_2_1_1a');
            ucRules('1.2.1.1b')=Xmessage('hdlcommon:IndustryStandard:rule_1_2_1_1b');
            ucRules('1.2.1.2')=Xmessage('hdlcommon:IndustryStandard:rule_1_2_1_2');
            ucRules('1.2.1.3')=Xmessage('hdlcommon:IndustryStandard:rule_1_2_1_3');
            ucRules('1.3.1.3')=Xmessage('hdlcommon:IndustryStandard:rule_1_3_1_3');

            ucRules('1.3.1.6')=Xmessage('hdlcommon:IndustryStandard:rule_1_3_1_6');
            ucRules('1.3.1.7')=Xmessage('hdlcommon:IndustryStandard:rule_1_3_1_7');
            ucRules('1.3.2.1a')=Xmessage('hdlcommon:IndustryStandard:rule_1_3_2_1a');
            ucRules('1.3.2.1b')=Xmessage('hdlcommon:IndustryStandard:rule_1_3_2_1b');
            ucRules('1.3.2.2')=Xmessage('hdlcommon:IndustryStandard:rule_1_3_2_2');
            ucRules('1.4.1.1')=Xmessage('hdlcommon:IndustryStandard:rule_1_4_1_1');

            ucRules('1.4.3.2')=Xmessage('hdlcommon:IndustryStandard:rule_1_4_3_2');
            ucRules('1.4.3.4')=Xmessage('hdlcommon:IndustryStandard:rule_1_4_3_4');
            ucRules('1.4.3.6')=Xmessage('hdlcommon:IndustryStandard:rule_1_4_3_6');
            ucRules('1.4.4.2')=Xmessage('hdlcommon:IndustryStandard:rule_1_4_4_2');
            ucRules('1.6.1.2')=Xmessage('hdlcommon:IndustryStandard:rule_1_6_1_2');
            ucRules('1.6.1.4')=Xmessage('hdlcommon:IndustryStandard:rule_1_6_1_4');
            ucRules('2.1.1.1v')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_1_1v');
            ucRules('2.1.1.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_1_2');
            ucRules('2.1.1.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_1_3');
            ucRules('2.1.2.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_2_1');
            ucRules('2.1.2.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_2_2');
            ucRules('2.1.2.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_2_3');
            ucRules('2.1.2.3v')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_2_3v');
            ucRules('2.1.2.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_2_4');
            ucRules('2.1.2.4v')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_2_4v');
            ucRules('2.1.2.5')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_2_5');
            ucRules('2.1.2.5v')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_2_5v');
            ucRules('2.1.2.6')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_2_6');
            ucRules('2.1.3.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_3_1');
            ucRules('2.1.3.1v')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_3_1v');
            ucRules('2.1.3.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_3_2');
            ucRules('2.1.3.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_3_3');
            ucRules('2.1.3.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_3_4');
            ucRules('2.1.3.4v')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_3_4v');
            ucRules('2.1.3.5')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_3_5');
            ucRules('2.1.4.5')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_4_5');
            ucRules('2.1.4.6a')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_4_6a');
            ucRules('2.1.4.6b')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_4_6b');
            ucRules('2.1.5.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_5_3');
            ucRules('2.1.6.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_6_2');
            ucRules('2.1.6.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_6_4');
            ucRules('2.1.6.5')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_6_5');
            ucRules('2.1.7.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_7_1');
            ucRules('2.1.8.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_8_1');
            ucRules('2.1.8.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_8_2');
            ucRules('2.1.8.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_8_4');
            ucRules('2.1.8.5a')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_8_5a');
            ucRules('2.1.8.5b')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_8_5b');
            ucRules('2.1.8.6')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_8_6');
            ucRules('2.1.8.9')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_8_9');
            ucRules('2.1.8.10')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_8_10');
            ucRules('2.1.9.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_9_4');
            ucRules('2.1.9.5')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_9_5');
            ucRules('2.1.10.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_10_1');
            ucRules('2.1.10.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_10_2');
            ucRules('2.1.10.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_10_3');
            ucRules('2.1.10.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_10_4');
            ucRules('2.1.10.5')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_10_5');
            ucRules('2.1.10.6')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_10_6');
            ucRules('2.1.10.8')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_10_8');
            ucRules('2.1.10.9')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_10_9');
            ucRules('2.1.10.10')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_10_10');
            ucRules('2.1.10.11')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_10_11');
            ucRules('2.1.10.12')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_10_12');
            ucRules('2.1.10.13')=Xmessage('hdlcommon:IndustryStandard:rule_2_1_10_13');
            ucRules('2.2.1.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_2_1_2');
            ucRules('2.2.2.2a')=Xmessage('hdlcommon:IndustryStandard:rule_2_2_2_2a');
            ucRules('2.2.2.2b')=Xmessage('hdlcommon:IndustryStandard:rule_2_2_2_2b');
            ucRules('2.2.2.3a')=Xmessage('hdlcommon:IndustryStandard:rule_2_2_2_3a');
            ucRules('2.2.2.3b')=Xmessage('hdlcommon:IndustryStandard:rule_2_2_2_3b');
            ucRules('2.2.2.3v')=Xmessage('hdlcommon:IndustryStandard:rule_2_2_2_3v');
            ucRules('2.2.3.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_2_3_1');
            ucRules('2.2.3.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_2_3_2');
            ucRules('2.2.3.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_2_3_3');
            ucRules('2.3.1.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_1');
            ucRules('2.3.1.2a')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_2a');
            ucRules('2.3.1.2b')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_2b');
            ucRules('2.3.1.2c')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_2c');
            ucRules('2.3.1.2va')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_2va');
            ucRules('2.3.1.2vb')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_2vb');
            ucRules('2.3.1.2vc')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_2vc');
            ucRules('2.3.1.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_4');
            ucRules('2.3.1.5a')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_5a');
            ucRules('2.3.1.5b')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_5b');
            ucRules('2.3.1.6')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_6');
            ucRules('2.3.1.7a')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_7a');
            ucRules('2.3.1.7b')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_7b');
            ucRules('2.3.1.8')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_8');
            ucRules('2.3.1.9')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_1_9');
            ucRules('2.3.2.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_2_1');
            ucRules('2.3.2.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_2_2');
            ucRules('2.3.2.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_2_4');
            ucRules('2.3.3.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_3_1');
            ucRules('2.3.3.2a')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_3_2a');
            ucRules('2.3.3.2b')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_3_2b');
            ucRules('2.3.6.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_6_1');
            ucRules('2.3.6.2a')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_6_2a');
            ucRules('2.4.1.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_4_1_2');
            ucRules('2.4.1.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_4_1_3');
            ucRules('2.4.1.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_4_1_4');
            ucRules('2.4.1.5')=Xmessage('hdlcommon:IndustryStandard:rule_2_4_1_5');
            ucRules('2.5.1.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_5_1_1');
            ucRules('2.5.1.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_5_1_2');
            ucRules('2.5.1.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_5_1_4');
            ucRules('2.5.1.5a')=Xmessage('hdlcommon:IndustryStandard:rule_2_5_1_5a');
            ucRules('2.5.1.5b')=Xmessage('hdlcommon:IndustryStandard:rule_2_5_1_5b');
            ucRules('2.5.1.6')=Xmessage('hdlcommon:IndustryStandard:rule_2_5_1_6');
            ucRules('2.5.1.7')=Xmessage('hdlcommon:IndustryStandard:rule_2_5_1_7');
            ucRules('2.5.1.8')=Xmessage('hdlcommon:IndustryStandard:rule_2_5_1_8');
            ucRules('2.5.1.9')=Xmessage('hdlcommon:IndustryStandard:rule_2_5_1_9');
            ucRules('2.5.2.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_5_2_1');



            ucRules('2.6.2.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_6_2_2');
            ucRules('2.7.2.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_7_2_2');
            if_else_depth=num2str(codingStdOptions.IfElseNesting.depth);
            ucRules('2.7.3.1a')=Xmessage1('hdlcommon:IndustryStandard:rule_2_7_3_1a',if_else_depth);
            ucRules('2.7.3.1b')=Xmessage('hdlcommon:IndustryStandard:rule_2_7_3_1b');
            if_else_chain=num2str(codingStdOptions.IfElseChain.length);
            ucRules('2.7.3.1c')=Xmessage1('hdlcommon:IndustryStandard:rule_2_7_3_1c',if_else_chain);
            ucRules('2.7.4.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_7_4_2');
            ucRules('2.7.4.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_7_4_3');
            ucRules('2.8.1.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_1_3');
            ucRules('2.8.1.5')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_1_5');
            ucRules('2.8.3.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_3_3');
            ucRules('2.8.3.4a')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_3_4a');
            ucRules('2.8.3.4b')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_3_4b');
            ucRules('2.8.3.5')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_3_5');
            ucRules('2.8.3.6')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_3_6');
            ucRules('2.8.3.7')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_3_7');
            ucRules('2.8.4.1a')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_4_1a');
            ucRules('2.8.4.1b')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_4_1b');
            ucRules('2.8.4.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_4_3');
            ucRules('2.8.4.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_4_4');
            ucRules('2.8.5.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_5_1');
            ucRules('2.8.5.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_5_2');
            ucRules('2.8.5.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_5_3');
            ucRules('2.8.5.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_8_5_4');
            ucRules('2.9.1.2a')=Xmessage('hdlcommon:IndustryStandard:rule_2_9_1_2a');
            ucRules('2.9.1.2b')=Xmessage('hdlcommon:IndustryStandard:rule_2_9_1_2b');
            ucRules('2.9.1.2c')=Xmessage('hdlcommon:IndustryStandard:rule_2_9_1_2c');
            ucRules('2.9.1.2d')=Xmessage('hdlcommon:IndustryStandard:rule_2_9_1_2d');
            ucRules('2.9.1.2e')=Xmessage('hdlcommon:IndustryStandard:rule_2_9_1_2e');
            ucRules('2.9.2.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_9_2_4');
            ucRules('2.9.3.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_9_3_1');



            ucRules('2.10.1.4v')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_1_4v');
            ucRules('2.10.1.4a')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_1_4a');
            ucRules('2.10.1.4b')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_1_4b');
            ucRules('2.10.1.4c')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_1_4c');
            ucRules('2.10.1.5')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_1_5');
            ucRules('2.10.1.6')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_1_6');
            ucRules('2.10.1.7')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_1_7');
            ucRules('2.10.1.8')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_1_8');
            ucRules('2.10.2.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_2_3');
            ucRules('2.10.3.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_3_1');
            ucRules('2.10.3.1v')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_3_1v');
            ucRules('2.10.3.2a')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_3_2a');
            ucRules('2.10.3.6')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_3_6');
            ucRules('2.10.4.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_4_3');
            ucRules('2.10.4.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_4_4');
            ucRules('2.10.4.5')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_4_5');
            ucRules('2.10.4.6v')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_4_6v');
            ucRules('2.10.4.8')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_4_8');
            ucRules('2.10.5.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_5_3');
            ucRules('2.10.5.5')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_5_5');
            ucRules('2.10.7.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_7_2');
            ucRules('2.10.8.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_8_1');
            ucRules('2.10.8.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_8_2');
            ucRules('2.10.8.3')=Xmessage('hdlcommon:IndustryStandard:rule_2_10_8_3');
            ucRules('2.11.1.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_11_1_4');
            ucRules('2.11.3.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_11_3_1');
            ucRules('2.11.5.2')=Xmessage('hdlcommon:IndustryStandard:rule_2_11_5_2');
            ucRules('3.1.2.7')=Xmessage('hdlcommon:IndustryStandard:rule_3_1_2_7');
            ucRules('3.1.3.1')=Xmessage('hdlcommon:IndustryStandard:rule_3_1_3_1');



            ucRules('3.1.3.4a')=Xmessage('hdlcommon:IndustryStandard:rule_3_1_3_4a');
            ucRules('3.1.4.4')=Xmessage('hdlcommon:IndustryStandard:rule_3_1_4_4');


            line_length=codingStdOptions.LineLength.length;

            ucRules('3.1.4.5')=Xmessage1('hdlcommon:IndustryStandard:rule_3_1_4_5',num2str(line_length));

            ucRules('3.1.6.1')=Xmessage('hdlcommon:IndustryStandard:rule_3_1_6_1');
            ucRules('3.2.2.2b')=Xmessage('hdlcommon:IndustryStandard:rule_3_2_2_2b');
            ucRules('3.2.2.4')=Xmessage('hdlcommon:IndustryStandard:rule_3_2_2_4');
            ucRules('3.2.2.5')=Xmessage('hdlcommon:IndustryStandard:rule_3_2_2_5');
            ucRules('3.2.2.7')=Xmessage('hdlcommon:IndustryStandard:rule_3_2_2_7');
            ucRules('3.2.3.1')=Xmessage('hdlcommon:IndustryStandard:rule_3_2_3_1');
            ucRules('3.2.3.1v')=Xmessage('hdlcommon:IndustryStandard:rule_3_2_3_1v');
            ucRules('3.2.3.2')=Xmessage('hdlcommon:IndustryStandard:rule_3_2_3_2');
            ucRules('3.2.3.3')=Xmessage('hdlcommon:IndustryStandard:rule_3_2_3_3');
            ucRules('3.2.4.1')=Xmessage('hdlcommon:IndustryStandard:rule_3_2_4_1');
            ucRules('3.2.4.3')=Xmessage('hdlcommon:IndustryStandard:rule_3_2_4_3');
            ucRules('3.3.1.1')=Xmessage('hdlcommon:IndustryStandard:rule_3_3_1_1');
            ucRules('3.3.1.4a')=Xmessage('hdlcommon:IndustryStandard:rule_3_3_1_4a');
            ucRules('3.3.2.3')=Xmessage('hdlcommon:IndustryStandard:rule_3_3_2_3');
            ucRules('3.3.3.1')=Xmessage('hdlcommon:IndustryStandard:rule_3_3_3_1');
            ucRules('3.3.6.2')=Xmessage('hdlcommon:IndustryStandard:rule_3_3_6_2');
            ucRules('3.5.2.1')=Xmessage('hdlcommon:IndustryStandard:rule_3_5_2_1');
            ucRules('3.5.2.1v')=Xmessage('hdlcommon:IndustryStandard:rule_3_5_2_1v');
            ucRules('3.5.6.2vb')=Xmessage('hdlcommon:IndustryStandard:rule_3_5_6_2vb');
            ucRules('3.5.6.3a')=Xmessage('hdlcommon:IndustryStandard:rule_3_5_6_3a');
            ucRules('3.5.6.4')=Xmessage('hdlcommon:IndustryStandard:rule_3_5_6_4');
            ucRules('3.5.6.6')=Xmessage('hdlcommon:IndustryStandard:rule_3_5_6_6');

            rules=ucRules;
        end








        function rules=getCheckedSTARCruleStruct()
            persistent STARCruleStruct;
            if(isempty(STARCruleStruct))

                STARCruleStruct=struct(...
                'a1',struct(...
                'a1',struct(...
                'a1',struct('a1','1.1.1.1','a2','1.1.1.2-3','a3vb','1.1.1.3vb','a4','1.1.1.4','a5','1.1.1.5','a6','1.1.1.6','a6v','1.1.1.6v','a9','1.1.1.9','a9d','1.1.1.9d','a10','1.1.1.10'),...
                'a2',struct('a1','1.1.2.1','a1b','1.1.2.1b'),...
                'a3',struct('a3','1.1.3.3','a3a','1.1.3.3a','a3b','1.1.3.3b','a3d','1.1.3.3d','a3e','1.1.3.3e'),...
                'a4',struct('a1','1.1.4.1','a1vb','1.1.4.1vb','a4','1.1.4.4','a4v','1.1.4.4v','a9','1.1.4.9','a9v','1.1.4.9v'),...
                'a5',struct('a2','1.1.5.2','a2a','1.1.5.2a'),...
                'a6',struct('a1','1.1.6.1','a4','1.1.6.4')),...
                'a2',struct(...
                'a1',struct('a1a','1.2.1.1a','a1b','1.2.1.1b','a2','1.2.1.2','a3','1.2.1.3')),...
                'a3',struct(...
                'a1',struct('a3','1.3.1.3','a6','1.3.1.6','a7','1.3.1.7'),...
                'a2',struct('a1a','1.3.2.1a','a1b','1.3.2.1b','a2','1.3.2.2')),...
                'a4',struct(...
                'a1',struct('a1','1.4.1.1'),...
                'a3',struct('a2','1.4.3.2','a4','1.4.3.4','a6','1.4.3.6'),...
                'a4',struct('a2','1.4.4.2')),...
                'a6',struct(...
                'a1',struct('a2','1.6.1.2','a4','1.6.1.4'))),...
                'a2',struct(...
                'a1',struct(...
                'a1',struct('a1v','2.1.1.1v','a2','2.1.1.2','a3','2.1.1.3'),...
                'a2',struct('a1','2.1.2.1','a2','2.1.2.2','a3','2.1.2.3','a3v','2.1.2.3v','a4','2.1.2.4','a4v','2.1.2.4v','a5','2.1.2.5','a5v','2.1.2.5v','a6','2.1.2.6'),...
                'a3',struct('a1','2.1.3.1','a1v','2.1.3.1v','a2','2.1.3.2','a3','2.1.3.3','a4','2.1.3.4','a4v','2.1.3.4v','a5','2.1.3.5'),...
                'a4',struct('a5','2.1.4.5','a6a','2.1.4.6a','a6b','2.1.4.6b'),...
                'a5',struct('a3','2.1.5.3'),...
                'a6',struct('a2','2.1.6.2','a4','2.1.6.4','a5','2.1.6.5'),...
                'a7',struct('a1','2.1.7.1'),...
                'a8',struct('a1','2.1.8.1','a2','2.1.8.2','a4','2.1.8.4','a5a','2.1.8.5a','a5b','2.1.8.5b','a6','2.1.8.6','a9','2.1.8.9','a10','2.1.8.10'),...
                'a9',struct('a4','2.1.9.4','a5','2.1.9.5'),...
                'a10',struct('a1','2.1.10.1','a2','2.1.10.2','a3','2.1.10.3','a4','2.1.10.4','a5','2.1.10.5','a6','2.1.10.6','a8','2.1.10.8','a9','2.1.10.9','a10','2.1.10.10','a11','2.1.10.11','a12','2.1.10.12','a13','2.1.10.13')),...
                'a2',struct(...
                'a1',struct('a2','2.2.1.2'),...
                'a2',struct('a2a','2.2.2.2a','a2b','2.2.2.2b','a3a','2.2.2.3a','a3b','2.2.2.3b','a3v','2.2.2.3v'),...
                'a3',struct('a1','2.2.3.1','a2','2.2.3.2','a3','2.2.3.3')),...
                'a3',struct(...
                'a1',struct('a1','2.3.1.1','a2a','2.3.1.2a','a2b','2.3.1.2b','a2c','2.3.1.2c','a2va','2.3.1.2va','a2vb','2.3.1.2vb','a2vc','2.3.1.2vc','a4','2.3.1.4','a5a','2.3.1.5a','a5b','2.3.1.5b','a6','2.3.1.6','a7a','2.3.1.7a','a7b','2.3.1.7b','a8','2.3.1.8','a9','2.3.1.9'),...
                'a2',struct('a1','2.3.2.1','a2','2.3.2.2','a4','2.3.2.4'),...
                'a3',struct('a1','2.3.3.1','a2a','2.3.3.2a','a2b','2.3.3.2b','a4','2.3.3.4','a5','2.3.3.5','a6','2.3.3.6'),...
                'a4',struct('a1','2.3.4.1'),...
                'a6',struct('a1','2.3.6.1','a2a','2.3.6.2a')),...
                'a4',struct(...
                'a1',struct('a2','2.4.1.2','a3','2.4.1.3','a4','2.4.1.4','a5','2.4.1.5')),...
                'a5',struct(...
                'a1',struct('a1','2.5.1.1','a2','2.5.1.2','a4','2.5.1.4','a5a','2.5.1.5a','a5b','2.5.1.5b','a6','2.5.1.6','a7','2.5.1.7','a8','2.5.1.8','a9','2.5.1.9'),...
                'a2',struct('a1','2.5.2.1')),...
                'a6',struct(...
                'a2',struct('a1','2.6.2.1','a1a','2.6.2.1a','a2','2.6.2.2')),...
                'a7',struct(...
                'a2',struct('a2','2.7.2.2'),...
                'a3',struct('a1a','2.7.3.1a','a1b','2.7.3.1b','a1c','2.7.3.1c'),...
                'a4',struct('a2','2.7.4.2','a3','2.7.4.3')),...
                'a8',struct(...
                'a1',struct('a3','2.8.1.3','a5','2.8.1.5'),...
                'a3',struct('a3','2.8.3.3','a4a','2.8.3.4a','a4b','2.8.3.4b','a5','2.8.3.5','a6','2.8.3.6','a7','2.8.3.7'),...
                'a4',struct('a1a','2.8.4.1a','a1b','2.8.4.1b','a3','2.8.4.3','a4','2.8.4.4'),...
                'a5',struct('a1','2.8.5.1','a2','2.8.5.2','a3','2.8.5.3','a4','2.8.5.4')),...
                'a9',struct(...
                'a1',struct('a2a','2.9.1.2a','a2b','2.9.1.2b','a2c','2.9.1.2c','a2d','2.9.1.2d','a2e','2.9.1.2e'),...
                'a2',struct('a4','2.9.2.4'),...
                'a3',struct('a1','2.9.3.1')),...
                'a10',struct(...
                'a1',struct('a4a','2.10.1.4a','a4b','2.10.1.4b','a4c','2.10.1.4c','a4v','2.10.1.4v','a5','2.10.1.5','a6','2.10.1.6','a7','2.10.1.7','a8','2.10.1.8'),...
                'a2',struct('a3','2.10.2.3'),...
                'a3',struct('a1','2.10.3.1','a1v','2.10.3.1v','a2a','2.10.3.2a','a6','2.10.3.6'),...
                'a4',struct('a3','2.10.4.3','a4','2.10.4.4','a5','2.10.4.5','a6v','2.10.4.6v','a8','2.10.4.8'),...
                'a5',struct('a3','2.10.5.3','a5','2.10.5.5'),...
                'a6',struct('a5','2.10.6.5'),...
                'a7',struct('a2','2.10.7.2'),...
                'a8',struct('a1','2.10.8.1','a2','2.10.8.2','a3','2.10.8.3')),...
                'a11',struct(...
                'a1',struct('a4','2.11.1.4'),...
                'a3',struct('a1','2.11.3.1'),...
                'a5',struct('a2','2.11.5.2'))),...
                'a3',struct(...
                'a1',struct(...
                'a2',struct('a7','3.1.2.7'),...
                'a3',struct('a1','3.1.3.1','a4a','3.1.3.4a'),...
                'a4',struct('a4','3.1.4.4','a5','3.1.4.5'),...
                'a6',struct('a1','3.1.6.1')),...
                'a2',struct(...
                'a2',struct('a2b','3.2.2.2b','a4','3.2.2.4','a5','3.2.2.5','a7','3.2.2.7'),...
                'a3',struct('a1','3.2.3.1','a1v','3.2.3.1v','a2','3.2.3.2','a3','3.2.3.3'),...
                'a4',struct('a1','3.2.4.1','a3','3.2.4.3')),...
                'a3',struct(...
                'a1',struct('a1','3.3.1.1','a4a','3.3.1.4a'),...
                'a2',struct('a3','3.3.2.3'),...
                'a3',struct('a1','3.3.3.1'),...
                'a6',struct('a2','3.3.6.2')),...
                'a5',struct(...
                'a2',struct('a1','3.5.2.1','a1v','3.5.2.1v'),...
                'a6',struct('a2vb','3.5.6.2vb','a3a','3.5.6.3a','a4','3.5.6.4','a6','3.5.6.6'))));
            end

            rules=STARCruleStruct;
            return
        end
    end
end
