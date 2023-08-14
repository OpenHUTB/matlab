






function make_formatters



    create_formatter('MSG_SF_ACTIVE_ON_ENTRY','','');
    create_formatter('MSG_SF_ENTER_FROM_TRANSITION','','');
    create_formatter('MSG_SF_INACTIVE_CHILDREN','','');
    create_formatter('MSG_SF_INACTIVE_PARENT_AFTER_ENTRY','','');
    create_formatter('MSG_SF_INACTIVE_PARENT_AFTER_SIB_ENTRY','','');
    create_formatter('MSG_SF_INACTIVE_AFTER_ENTRY_EVENT','','');
    create_formatter('MSG_SF_ENTER_FROM_OUTSIDE','','');
    create_formatter('MSG_SF_PREV_ACTIVE_CHILD','','');
    create_formatter('MSG_SF_HIST_CHILD_CALL','','');
    create_formatter('MSG_SF_INACTIVE_AFTER_CHILD_ENTRY','','');
    create_formatter('MSG_SF_INACTIVE_CHILD_FROM_HIST','','');
    create_formatter('MSG_SF_ENTER_SET_FROM_OUTSIDE','','');
    create_formatter('MSG_SF_INACTIVE_AFTER_DEFAULT','','');
    create_formatter('MSG_SF_INACTIVE_BEFORE_DURING','','');
    create_formatter('MSG_SF_INACTIVE_CHILDREN_DURING','','');
    create_formatter('MSG_SF_STATE_ON_DECISION','%s','');



    create_formatter('MSG_SF_TRANSITION_TEST','','');
    create_formatter('MSG_SF_TRANS_PRED','%s','%d %s');
    create_formatter('MSG_SF_ACTIVE_CHILD_CALL','','');
    create_formatter('MSG_SF_INACTIVE_BEFORE_EXIT','','');
    create_formatter('MSG_SF_ACTIVE_CHILD_AT_EXIT','','');
    create_formatter('MSG_SF_ACTIVE_CHILD_EXIT','','');
    create_formatter('MSG_SF_INACTIVE_AFTER_CHILD_EXIT','','');


    create_formatter('MSG_SL_BLOCK_COVERAGE','','');



    create_formatter('MSG_SL_TESTPOINT','%s','');
    create_formatter('MSG_SL_TESTINTERVAL','%s','');
    create_formatter('MSG_SL_TESTOBJECTIVE_SCAL','%s','');
    create_formatter('MSG_SL_TESTOBJECTIVE_VECT','%d','');


    create_formatter('MSG_SL_SATURATE_ON_INTEGER_OVERFLOW','','');



    create_formatter('MSG_SL_ABSVAL_SCAL','U %s 0','');
    create_formatter('MSG_SL_ABSVAL_VECT','U(%d) %s 0','');
    create_formatter('MSG_SL_ABSVAL_VECTC','U(:) %s 0','');



    create_formatter('MSG_SL_RELATIONALOP_OUTCOME_INT_LESS','','');
    create_formatter('MSG_SL_RELATIONALOP_OUTCOME_FIXPT_LESS','','');
    create_formatter('MSG_SL_RELATIONALOP_OUTCOME_REAL_LESS','','');
    create_formatter('MSG_SL_RELATIONALOP_OUTCOME_REAL_LESS_CLOSED','','');
    create_formatter('MSG_SL_RELATIONALOP_OUTCOME_INT_EQ','','');
    create_formatter('MSG_SL_RELATIONALOP_OUTCOME_FIXPT_EQ','','');
    create_formatter('MSG_SL_RELATIONALOP_OUTCOME_INT_GREATER','','');
    create_formatter('MSG_SL_RELATIONALOP_OUTCOME_FIXPT_GREATER','','');
    create_formatter('MSG_SL_RELATIONALOP_OUTCOME_REAL_GREATER','','');
    create_formatter('MSG_SL_RELATIONALOP_OUTCOME_REAL_GREATER_CLOSED','','');



    create_formatter('MSG_SL_RELATIONALOP_SCAL','%s','');
    create_formatter('MSG_SL_RELATIONALOP_VEC','%d %s %d','');
    create_formatter('MSG_SL_RELATIONALOP_VEC_SCAL','%d %s','');
    create_formatter('MSG_SL_RELATIONALOP_SCAL_VEC','%s %d','');
    create_formatter('MSG_SL_RELATIONALOP_COND_UNARY','%s','');
    create_formatter('MSG_SL_RELATIONALOP_COND_UNARY_VEC','%d %s','');


    create_formatter('MSG_SL_RELAY_ON_SCAL','%s','');
    create_formatter('MSG_SL_RELAY_ON_VECTU','%d %s','')
    create_formatter('MSG_SL_RELAY_ON_VECTP','%s %d','');
    create_formatter('MSG_SL_RELAY_ON_VECTUP','%d %s %d','');
    create_formatter('MSG_SL_RELAY_OFF_SCAL','%s','');
    create_formatter('MSG_SL_RELAY_OFF_VECTU','%d %s','')
    create_formatter('MSG_SL_RELAY_OFF_VECTP','%s %d','');
    create_formatter('MSG_SL_RELAY_OFF_VECTUP','%d %s %d','');


    create_formatter('MSG_SL_SATURATE_UL_SCAL','%s','');
    create_formatter('MSG_SL_SATURATE_UL_VECTU','%d %s','')
    create_formatter('MSG_SL_SATURATE_UL_VECTP','%s %d','');
    create_formatter('MSG_SL_SATURATE_UL_VECTUP','%d %s %d','');
    create_formatter('MSG_SL_SATURATE_LL_SCAL','%s','');
    create_formatter('MSG_SL_SATURATE_LL_VECTU','%d %s','')
    create_formatter('MSG_SL_SATURATE_LL_VECTP','%s %d','');
    create_formatter('MSG_SL_SATURATE_LL_VECTUP','%d %s %d','');

    create_formatter('MSG_SL_DEADZONE_UL_SCAL','%s','');
    create_formatter('MSG_SL_DEADZONE_UL_VECTU','%d %s','')
    create_formatter('MSG_SL_DEADZONE_UL_VECTP','%s %d','');
    create_formatter('MSG_SL_DEADZONE_UL_VECTUP','%d %s %d','');
    create_formatter('MSG_SL_DEADZONE_LL_SCAL','%s','');
    create_formatter('MSG_SL_DEADZONE_LL_VECTU','%d %s','')
    create_formatter('MSG_SL_DEADZONE_LL_VECTP','%s %d','');
    create_formatter('MSG_SL_DEADZONE_LL_VECTUP','%d %s %d','');


    create_formatter('MSG_SL_DINTEGRATOR_RESET_SCAL','','');
    create_formatter('MSG_SL_DINTEGRATOR_RESET_VECT','%d','');
    create_formatter('MSG_SL_DINTEGRATOR_UL_SCAL','','');
    create_formatter('MSG_SL_DINTEGRATOR_UL_VECTU','%d','')
    create_formatter('MSG_SL_DINTEGRATOR_UL_VECTP','%d','');
    create_formatter('MSG_SL_DINTEGRATOR_UL_VECTUP','%d %d','');
    create_formatter('MSG_SL_DINTEGRATOR_LL_SCAL','','');
    create_formatter('MSG_SL_DINTEGRATOR_LL_VECTU','%d','')
    create_formatter('MSG_SL_DINTEGRATOR_LL_VECTP','%d','');
    create_formatter('MSG_SL_DINTEGRATOR_LL_VECTUP','%d %d','');



    create_formatter('MSG_SL_RATELIMITER_UL_SCAL','%s','');
    create_formatter('MSG_SL_RATELIMITER_UL_VECTU','%d %s','')
    create_formatter('MSG_SL_RATELIMITER_UL_VECTP','%s %d','');
    create_formatter('MSG_SL_RATELIMITER_UL_VECTUP','%d %s %d','');
    create_formatter('MSG_SL_RATELIMITER_LL_SCAL','%s','');
    create_formatter('MSG_SL_RATELIMITER_LL_VECTU','%d %s','')
    create_formatter('MSG_SL_RATELIMITER_LL_VECTP','%s %d','');
    create_formatter('MSG_SL_RATELIMITER_LL_VECTUP','%d %s %d','');


    create_formatter('MSG_SL_FCN_CONDITION','%s','');
    create_formatter('MSG_SL_FCN_TEST','','');


    create_formatter('MSG_SL_LOGIC_SCAL','%d','');
    create_formatter('MSG_SL_LOGIC_VECT','%d1 %d2','');
    create_formatter('MSG_SL_LOGIC_SCAL_OUT','','');
    create_formatter('MSG_SL_LOGIC_VECT_OUT','%d','');



    create_formatter('MSG_SL_CMBLOGIC_SCAL','','');
    create_formatter('MSG_SL_CMBLOGIC_VECT','','');
    create_formatter('MSG_SL_CMBLOGIC_ELM','%d','');
    create_formatter('MSG_SL_CMBLOGIC_OUT','%d %s','');



    create_formatter('MSG_SL_IF_SING_IF','','');
    create_formatter('MSG_SL_IF_MULT_IF','%d','');
    create_formatter('MSG_SL_IF_MULT_ELSEIF','%d','');


    create_formatter('MSG_SL_FOR_CHECK','','');
    create_formatter('MSG_SL_LOOPEXEC','','');



    create_formatter('MSG_SL_WHILE_WHILETEST','','');
    create_formatter('MSG_SL_WHILE_DOWHILETEST','','');
    create_formatter('MGG_SL_WHILE_MAXITERS','','');



    create_formatter('MSG_SL_MINMAX_SCAL','','');
    create_formatter('MSG_SL_MINMAX_VECT','%d','');
    create_formatter('MSG_SL_MIN_IDX','%d','');
    create_formatter('MSG_SL_MINMAX_VECT','%d','');
    create_formatter('MSG_SL_MAX_IDX','%d','');



    create_formatter('MSG_SL_SUBSYS_FCALL','','');
    create_formatter('MSG_SL_SUBSYS_ENBLS','','');
    create_formatter('MSG_SL_SUBSYS_ENBLV','','');
    create_formatter('MSG_SL_SUBSYS_RESETS','','');
    create_formatter('MSG_SL_SUBSYS_TRIGS','','');
    create_formatter('MSG_SL_SUBSYS_TRIGV','','');
    create_formatter('MSG_SL_SUBSYS_ENBLS_TRIGS','','');
    create_formatter('MSG_SL_SUBSYS_ENBLS_TRIGV','','');
    create_formatter('MSG_SL_SUBSYS_ENBLV_TRIGS','','');
    create_formatter('MSG_SL_SUBSYS_ENBLV_TRIGV','','');
    create_formatter('MSG_SL_SUBSYS_ENBL_COND','','');
    create_formatter('MSG_SL_SUBSYS_ENBLV_COND','%d','');
    create_formatter('MSG_SL_SUBSYS_TRIG_COND','','');
    create_formatter('MSG_SL_SUBSYS_TRIGV_COND','%d','');



    create_formatter('MSG_SL_SWITCH_BOOL_SCAL','','');
    create_formatter('MSG_SL_SWITCH_BOOL_VECT','%d','');

    create_formatter('MSG_SL_SWITCH_REAL_SCAL','%s','');
    create_formatter('MSG_SL_SWITCH_REAL_VECTU','%d %s','');
    create_formatter('MSG_SL_SWITCH_REAL_VECTP','%s %d','');
    create_formatter('MSG_SL_SWITCH_REAL_VECTUP','%d %s %d','');

    create_formatter('MSG_SL_SWITCH_REAL_GT_SCAL','%s','');
    create_formatter('MSG_SL_SWITCH_REAL_GT_VECTU','%d %s','');
    create_formatter('MSG_SL_SWITCH_REAL_GT_VECTP','%s %d','');
    create_formatter('MSG_SL_SWITCH_REAL_GT_VECTUP','%d %s %d','');

    create_formatter('MSG_SL_SWITCH_OUTCOME_T','','');
    create_formatter('MSG_SL_SWITCH_OUTCOME_F','','');

    create_formatter('MSG_SL_SWITCH_REAL_SCAL_0','%s','');
    create_formatter('MSG_SL_SWITCH_REAL_VECTU_0','%d %s','');
    create_formatter('MSG_SL_SWITCH_REAL_VECTP_0','%s %d','');
    create_formatter('MSG_SL_SWITCH_REAL_VECTUP_0','%d %s %d','');


    create_formatter('MSG_SL_SWTCHCASE','','');
    create_formatter('MCG_SL_SWTCHCASE_OUTI','%s','');


    create_formatter('MSG_SL_SIGNUM_SCAL','','');
    create_formatter('MSG_SL_SIGNUM_VECT','%d','');
    create_formatter('MSG_SL_SIGNUM_OUTCOME_NEGATIVE','','');
    create_formatter('MSG_SL_SIGNUM_OUTCOME_ZERO','','');
    create_formatter('MSG_SL_SIGNUM_OUTCOME_POSITIVE','','');
    create_formatter('MSG_SL_SIGNUM_REL_SCAL','%s','');
    create_formatter('MSG_SL_SIGNUM_REL_VECT','%d %s','');



    create_formatter('MSG_SL_MPSWITCH_OUTCOME_PORT','%s %d','');
    create_formatter('MSG_SL_MPSWITCH_OUTCOME_ELMNT','%s %d','');
    create_formatter('MSG_SL_MPSWITCH_INT_SCAL_PORT','','');
    create_formatter('MSG_SL_MPSWITCH_INT_SCAL_ELMNT','','');
    create_formatter('MSG_SL_MPSWITCH_INT_VECT','%d','');
    create_formatter('MSG_SL_MPSWITCH_REAL_SCAL_PORT','','');
    create_formatter('MSG_SL_MPSWITCH_REAL_SCAL_ELMNT','','');
    create_formatter('MSG_SL_MPSWITCH_REAL_VECT','%d','');


    create_formatter('MSG_SC_MODE','%s','');
    create_formatter('MSG_SC_MODE_OUTI','%s','');


    create_formatter('MSG_OUT_CALL','','');
    create_formatter('MSG_OUT_IMPLICIT_DFLT','','');
    create_formatter('MSG_OUT_EXPLICIT','','');
    create_formatter('MSG_OUT_CASE','%s','');
    create_formatter('MSG_OUT_GENERIC_TXT','%s','');
    create_formatter('MSG_OUT_T','','');
    create_formatter('MSG_OUT_F','','');
    create_formatter('MSG_OUT_STATE','%o','');
    create_formatter('MSG_CUSTOM_TXT','%s','');

    function create_formatter(id,summaryFormatStr,detailFormatStr)
        if isempty(detailFormatStr)
            detailFormatStr=summaryFormatStr;
        end
        cv('new','formatter','.keyNum',...
        id,...
        '.uIdentifier',id,...
        '.summary.formatStr',summaryFormatStr,...
        '.detail.formatStr',detailFormatStr...
        );
