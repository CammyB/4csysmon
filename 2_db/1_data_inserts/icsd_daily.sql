INSERT INTO ODS.agg_icsd_interconnect_s_d_z
  (
  ICSD_DATETIME,
  f_rt_seqid,
  gsm_sv_seqid_orig,
  gsm_sv_seqid_dest,
  gsm_itg_seqid_in,
  gsm_itg_seqid_out,
  icsd_dial_code_out,
  gsm_cc_seqid,
  ca_cr_seqid,
  icsd_rate,
  icsd_duration,
  icsd_count
  )
  SELECT
    trunc(IC_RECORDTIMESTAMP, 'DD')                               as ICSD_DATETIME,
    F_RT_SEQID,
    gsm_sv_seqid_orig,
    gsm_sv_seqid_dest,
    -1                                                            as gsm_itg_seqid_in,
    gsm_itg_seqid_out_parent                                      as gsm_itg_seqid_out,
    substr(ic_OTHERPARTY,0,4)                                     as icsd_dial_code_out,
    -1                                                            as gsm_cc_seqid,
    62                                                            as ca_cr_seqid,
    0.20                                                          as icsd_rate,
    sum(ic_duration)                                              as icsd_duration,
    count(*)                                                      as icsd_count
  from
    ODS.fct_ic_interconnect_cdr
  WHERE
    IC_RECORDTIMESTAMP >= trunc(sysdate - 1, 'DD')
    and IC_RECORDTIMESTAMP < trunc(sysdate, 'DD')
    and f_rt_seqid = 444
    and gsm_itg_seqid_out_parent = 561 -- VODACOM SA
  group by
    trunc(IC_RECORDTIMESTAMP, 'DD'),
    F_RT_SEQID,
    gsm_sv_seqid_orig,
    gsm_sv_seqid_dest,
    gsm_itg_seqid_out_parent,
    substr(ic_OTHERPARTY,0,4)
  UNION ALL
  SELECT
    trunc(IC_RECORDTIMESTAMP, 'DD')                               as ICSD_DATETIME,
    F_RT_SEQID,
    gsm_sv_seqid_orig,
    gsm_sv_seqid_dest,
    -1                                                            as gsm_itg_seqid_in,
    gsm_itg_seqid_out_parent                                      as gsm_itg_seqid_out,
    substr(ic_OTHERPARTY,0,4)                                     as icsd_dial_code_out,
    -1                                                            as gsm_cc_seqid,
    62                                                            as ca_cr_seqid,
    1.50                                                          as icsd_rate,
    sum(ic_duration)                                              as icsd_duration,
    count(*)                                                      as icsd_count
  from
    ODS.fct_ic_interconnect_cdr
  where
    IC_RECORDTIMESTAMP >= trunc(sysdate - 1, 'DD')
    and IC_RECORDTIMESTAMP < trunc(sysdate, 'DD')
    and f_rt_seqid = 444
    and gsm_itg_seqid_out_parent = 802 --MTN SA
  group by
    trunc(IC_RECORDTIMESTAMP, 'DD'),
    F_RT_SEQID,
    gsm_sv_seqid_orig,
    gsm_sv_seqid_dest,
    gsm_itg_seqid_out_parent,
    substr(ic_OTHERPARTY,0,4)
  union all
  SELECT
    trunc(IC_RECORDTIMESTAMP, 'DD')                               AS ICSD_DATETIME,
    F_RT_SEQID                                                    as F_RT_SEQID,
    gsm_sv_seqid_orig                                             as gsm_sv_seqid_orig,
    gsm_sv_seqid_dest                                             as gsm_sv_seqid_dest,
    -1                                                            as gsm_itg_seqid_in,
    case when gsm_sv_seqid_orig = 5115 and gsm_sv_seqid_dest = 5088 then 123  -- Econet Mobile
          when gsm_sv_seqid_orig = 5115 and gsm_sv_seqid_dest in (6144,6166) then 136  -- Econet Fixed
          else 140  -- Econet International
          end                                                    as gsm_itg_seqid_out,
    substr(ic_otherparty,0,4)                                     as icsd_dial_code_out,
    -1                                                            as gsm_cc_seqid,
    62                                                            as ca_cr_seqid,
    case when gsm_sv_seqid_orig = 5115 and gsm_sv_seqid_dest in (5088,6144,6166) then 0.38
           when gsm_sv_seqid_orig = 5100 then 3
           when gsm_sv_seqid_dest = 5100 then 3
           when gsm_sv_seqid_orig = 5115 and gsm_sv_seqid_dest not in (5088,6144,6166,5100) then 0.72
           when gsm_sv_seqid_orig not in (5115,5100) and gsm_sv_seqid_dest  <> 5100 then 0.72
           end                                                    as icsd_rate,
    sum(ic_duration)                                              as icsd_duration,
    count(*)                                                      as icsd_count
  FROM
    ODS.FCT_IC_INTERCONNECT_CDR
  WHERE
    IC_RECORDTIMESTAMP >= trunc(sysdate - 1, 'DD')
    and IC_RECORDTIMESTAMP < trunc(sysdate, 'DD')
    AND F_RT_SEQID = 444                            -- OUTGOING TRAFFIC
    AND GSM_ITG_SEQID_OUT_PARENT in (123,136,140)   -- ECONET TRUNKS
  GROUP BY
    trunc(IC_RECORDTIMESTAMP, 'DD'),
    F_RT_SEQID,
    gsm_sv_seqid_orig,
    gsm_sv_seqid_dest,
    case when gsm_sv_seqid_orig = 5115 and gsm_sv_seqid_dest = 5088 then 123  -- Econet Mobile
          when gsm_sv_seqid_orig = 5115 and gsm_sv_seqid_dest in (6144,6166) then 136  -- Econet Fixed
          else 140  -- Econet International
          end,
    substr(ic_otherparty,0,4),
    case when gsm_sv_seqid_orig = 5115 and gsm_sv_seqid_dest in (5088,6144,6166) then 0.38
           when gsm_sv_seqid_orig = 5100 then 3
           when gsm_sv_seqid_dest = 5100 then 3
           when gsm_sv_seqid_orig = 5115 and gsm_sv_seqid_dest not in (5088,6144,6166,5100) then 0.72
           when gsm_sv_seqid_orig not in (5115,5100) and gsm_sv_seqid_dest  <> 5100 then 0.72
           end
  union all
  SELECT
    trunc(fct.IC_RECORDTIMESTAMP, 'DD')                           as ICSD_DATETIME,
    444                                                           as F_RT_SEQID,
    fct.gsm_sv_seqid_orig                                         as GSM_SV_SEQID_ORIG,
    fct.gsm_sv_seqid_dest                                         as GSM_SV_SEQID_DEST,
    -1                                                            as GSM_ITG_SEQID_IN,
    fct.gsm_itg_seqid_out_parent                                  as GSM_ITG_SEQID_OUT,
    odc.idc_code                                                  as GSM_IDC_CODE_OUT,
    -1                                                            as ICSD_REF_COUNTRY,
    rate.ir_cr_id                                                 as ICSD_REF_CURRENCY,
    rate.ir_rate                                                  as ICSD_RATE,
    SUM(fct.IC_DURATION)                                          AS ICSD_DURATION,
    COUNT(*)                                                      AS ICSD_COUNT
  FROM
    ODS.FCT_IC_INTERCONNECT_CDR     fct,
    insight.GSM_IR_IC_RATE          rate,
    insight.gsm_idc_ic_dial_code    odc,
    insight.gsm_itg_ic_trunk_group  itg
  WHERE
    IC_RECORDTIMESTAMP >= trunc(sysdate - 1, 'DD')
    and IC_RECORDTIMESTAMP < trunc(sysdate, 'DD')
    AND fct.F_RT_SEQID = 444                                              -- OUT TRAFFIC
    AND fct.gsm_itg_seqid_out_parent in (125,301)                         -- TELKOM SA, GATEWAY
    AND fct.gsm_itg_seqid_out_parent = itg.itg_seqid                      -- matching for rates
    and fct.gsm_idc_seqid_outgoing = odc.idc_seqid                        -- matching for rates
    and itg.itg_id = odc.idc_itg_id                                       -- matching for rates
    and itg.itg_id = rate.ir_outgoing_itg_id
    and odc.idc_id = rate.ir_dest_idc_id
    and rate.ir_tz_id = -1
    and fct.ic_recordtimestamp >= rate.ir_startdate
    and fct.ic_recordtimestamp < rate.ir_enddate
  group by
    trunc(fct.IC_RECORDTIMESTAMP, 'DD'),
    fct.gsm_sv_seqid_orig,
    fct.gsm_sv_seqid_dest,
    fct.gsm_itg_seqid_out_parent,
    odc.idc_code,
    rate.ir_cr_id,
    rate.ir_rate
  union all
  SELECT
    trunc(IC_RECORDTIMESTAMP, 'DD')                               as ICSD_DATETIME,
    F_RT_SEQID,
    gsm_sv_seqid_orig,
    gsm_sv_seqid_dest,
    gsm_itg_seqid_in_parent                                       as gsm_itg_seqid_in,
    -1                                                            as gsm_itg_seqid_out,
    substr(ic_msisdn,0,4)                                         as icsd_dial_code_out,
    -1                                                            as gsm_cc_seqid,
    62                                                            as ca_cr_seqid,
    case when gsm_sv_seqid_dest = 5115 and gsm_sv_seqid_orig <> 5100 then 0.74
        when gsm_sv_seqid_dest = 5115 and gsm_sv_seqid_orig = 5100 then 2.77
        when gsm_sv_seqid_dest <> 5115 and gsm_sv_seqid_orig <> 5100 then 1.07
        when gsm_sv_seqid_dest <> 5115 and gsm_sv_seqid_orig = 5100 then 3.10
        else -1 end                                               as icsd_rate,
    sum(ic_duration)                                              as icsd_duration,
    count(*)                                                      as icsd_count
  from
    ODS.fct_ic_interconnect_cdr
  where
    IC_RECORDTIMESTAMP >= trunc(sysdate - 1, 'DD')
    and IC_RECORDTIMESTAMP < trunc(sysdate, 'DD')
    and f_rt_seqid = 443
    and gsm_itg_seqid_in_parent in (125,301)
  group by
    trunc(IC_RECORDTIMESTAMP, 'DD'),
    F_RT_SEQID,
    gsm_sv_seqid_orig,
    gsm_sv_seqid_dest,
    gsm_itg_seqid_in_parent,
    substr(ic_msisdn,0,4),
    case when gsm_sv_seqid_dest = 5115 and gsm_sv_seqid_orig <> 5100 then 0.74
        when gsm_sv_seqid_dest = 5115 and gsm_sv_seqid_orig = 5100 then 2.77
        when gsm_sv_seqid_dest <> 5115 and gsm_sv_seqid_orig <> 5100 then 1.07
        when gsm_sv_seqid_dest <> 5115 and gsm_sv_seqid_orig = 5100 then 3.10
        else -1 end
  UNION ALL
  SELECT
    trunc(IC_RECORDTIMESTAMP, 'DD')                               as ICSD_DATETIME,
    F_RT_SEQID,
    gsm_sv_seqid_orig,
    gsm_sv_seqid_dest,
    gsm_itg_seqid_in_parent                                       as gsm_itg_seqid_in,
    -1                                                            as gsm_itg_seqid_out,
    substr(ic_msisdn,0,4)                                         as icsd_dial_code_out,
    -1                                                            as gsm_cc_seqid,
    62                                                            as ca_cr_seqid,
    1.50                                                          as icsd_rate,
    sum(ic_duration)                                              as icsd_duration,
    count(*)                                                      as icsd_count
  from
    ODS.fct_ic_interconnect_cdr
  where
    IC_RECORDTIMESTAMP >= trunc(sysdate - 1, 'DD')
    and IC_RECORDTIMESTAMP < trunc(sysdate, 'DD')
    and f_rt_seqid = 443
    and gsm_itg_seqid_in_parent in (802)
  group by
    trunc(IC_RECORDTIMESTAMP, 'DD'),
    F_RT_SEQID,
    gsm_sv_seqid_orig,
    gsm_sv_seqid_dest,
    gsm_itg_seqid_in_parent,
    substr(ic_msisdn,0,4)
  UNION ALL
  SELECT
    trunc(IC_RECORDTIMESTAMP, 'DD')                               as ICSD_DATETIME,
    F_RT_SEQID,
    gsm_sv_seqid_orig,
    gsm_sv_seqid_dest,
    case when gsm_sv_seqid_dest = 5115 and gsm_sv_seqid_orig = 5088 then 123
         when gsm_sv_seqid_dest = 5115 and gsm_sv_seqid_orig in (6144,6166) then 136
         else 140 end as gsm_itg_seqid_in,
    -1                                                            as gsm_itg_seqid_out,
    substr(ic_msisdn,0,4)                                         as icsd_dial_code_out,
    -1                                                            as gsm_cc_seqid,
    62                                                            as ca_cr_seqid,
    case when gsm_sv_seqid_dest = 5115 and gsm_sv_seqid_orig in (5088,6144,6166) then 0.38
         when gsm_sv_seqid_orig = 5100 then 3
         when gsm_sv_seqid_dest = 5100 then 3
         when gsm_sv_seqid_dest = 5115 and gsm_sv_seqid_orig not in (5088,6144,6166,5100) then 0.72
         when gsm_sv_seqid_dest not in (5115,5100) and gsm_sv_seqid_orig  <> 5100 then 0.72
         end                                                      as icsd_rate,
    sum(ic_duration)                                              as icsd_duration,
    count(*)                                                      as icsd_count
  from
    ODS.fct_ic_interconnect_cdr
  where
    IC_RECORDTIMESTAMP >= trunc(sysdate - 1, 'DD')
    and IC_RECORDTIMESTAMP < trunc(sysdate, 'DD')
    and f_rt_seqid = 443
    and gsm_itg_seqid_in_parent in (123,136,140)
  group by
    trunc(IC_RECORDTIMESTAMP, 'DD'),
    F_RT_SEQID,
    gsm_sv_seqid_orig,
    gsm_sv_seqid_dest,
    case when gsm_sv_seqid_dest = 5115 and gsm_sv_seqid_orig = 5088 then 123
         when gsm_sv_seqid_dest = 5115 and gsm_sv_seqid_orig in (6144,6166) then 136
         else 140 end,
    substr(ic_msisdn,0,4),
    case when gsm_sv_seqid_dest = 5115 and gsm_sv_seqid_orig in (5088,6144,6166) then 0.38
         when gsm_sv_seqid_orig = 5100 then 3
         when gsm_sv_seqid_dest = 5100 then 3
         when gsm_sv_seqid_dest = 5115 and gsm_sv_seqid_orig not in (5088,6144,6166,5100) then 0.72
         when gsm_sv_seqid_dest not in (5115,5100) and gsm_sv_seqid_orig  <> 5100 then 0.72
         end
  UNION ALL
  SELECT
    trunc(IC_RECORDTIMESTAMP, 'DD')                               as ICSD_DATETIME,
    F_RT_SEQID,
    gsm_sv_seqid_orig,
    gsm_sv_seqid_dest,
    gsm_itg_seqid_in_parent                                       as gsm_itg_seqid_in,
    -1                                                            as gsm_itg_seqid_out,
    substr(ic_msisdn,0,4)                                         as icsd_dial_code_out,
    -1                                                            as gsm_cc_seqid,
    62                                                            as ca_cr_seqid,
    0.74                                                          as icsd_rate,
    sum(ic_duration)                                              as icsd_duration,
    count(*)                                                      as icsd_count
  from
    ODS.fct_ic_interconnect_cdr
  where
    IC_RECORDTIMESTAMP >= trunc(sysdate - 1, 'DD')
    and IC_RECORDTIMESTAMP < trunc(sysdate, 'DD')
    and f_rt_seqid = 443
    and gsm_itg_seqid_in_parent in (561)
  group by
    trunc(IC_RECORDTIMESTAMP, 'DD'),
    F_RT_SEQID,
    gsm_sv_seqid_orig,
    gsm_sv_seqid_dest,
    GSM_ITG_SEQID_IN_PARENT,
    substr(ic_msisdn,0,4);
COMMIT;
exit
