CREATE TABLE sa_calendar
    AS
        ( SELECT
            trunc(sd + rn)                                                                  time_id,
            to_char(sd + rn, 'fmDay')                                                       day_name,
            to_char(sd + rn, 'D')                                                           day_number_in_week,
            to_char(sd + rn, 'DD')                                                          day_number_in_month,
            to_char(sd + rn, 'DDD')                                                         day_number_in_year,
            to_char(sd + rn, 'W')                                                           calendar_week_number,
            (
                CASE
                    WHEN to_char(sd + rn, 'D') IN ( 1, 2, 3, 4, 5,
                                                    6 ) THEN
                        next_day(sd + rn, 'ВОСКРЕСЕНЬЕ')
                    ELSE
                        ( sd + rn )
                END
            )                                                                                 week_ending_date,
            to_char(sd + rn, 'MM')                                                          calendar_month_number,
            to_char(last_day(sd + rn), 'DD')                                              days_in_cal_month,
            last_day(sd + rn)                                                               end_of_cal_month,
            to_char(sd + rn, 'FMMonth')                                                     calendar_month_name,
            ( (
                CASE
                    WHEN to_char(sd + rn, 'Q') = 1    THEN
                        to_date('03/31/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    WHEN to_char(sd + rn, 'Q') = 2    THEN
                        to_date('06/30/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    WHEN to_char(sd + rn, 'Q') = 3    THEN
                        to_date('09/30/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    WHEN to_char(sd + rn, 'Q') = 4    THEN
                        to_date('12/31/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                END
            ) - trunc(sd + rn, 'Q') + 1 )                                                   days_in_cal_quarter,
            trunc(sd + rn, 'Q')                                                             beg_of_cal_quarter,
            (
                CASE
                    WHEN to_char(sd + rn, 'Q') = 1    THEN
                        to_date('03/31/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    WHEN to_char(sd + rn, 'Q') = 2    THEN
                        to_date('06/30/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    WHEN to_char(sd + rn, 'Q') = 3    THEN
                        to_date('09/30/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                    WHEN to_char(sd + rn, 'Q') = 4    THEN
                        to_date('12/31/'
                                || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')
                END
            )                                                                                 end_of_cal_quarter,
            to_char(sd + rn, 'Q')                                                           calendar_quarter_number,
            to_char(sd + rn, 'YYYY')                                                        calendar_year,
            ( to_date('12/31/'
                      || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY') - trunc(sd + rn, 'YEAR') )   days_in_cal_year,
            trunc(sd + rn, 'YEAR')                                                          beg_of_cal_year,
            to_date('12/31/'
                    || to_char(sd + rn, 'YYYY'), 'MM/DD/YYYY')                                     end_of_cal_year
        FROM
            (
                SELECT
                    TO_DATE('12/31/2018', 'MM/DD/YYYY')    sd,
                    ROWNUM                                   rn
                FROM
                    dual
                CONNECT BY
                    level <= 2190
      --2190 works better
              )
        )

CREATE TABLE t_days
    AS
        ( SELECT
            time_id,
            day_name,
            day_number_in_week,
            day_number_in_month,
            day_number_in_year
        FROM
            sa_calendar
        );

ALTER TABLE t_days ADD CONSTRAINT time_id_pk PRIMARY KEY ( time_id );


CREATE TABLE t_weeks
    AS
        ( SELECT DISTINCT
            to_number(to_char(week_ending_date, 'yyyy')
                      || to_char(week_ending_date, 'MM')
                      || to_char(week_ending_date, 'DD'))        AS week_id,
            trunc(time_id, 'DAY')                      AS week_beg_date,
            week_ending_date
        FROM
            sa_calendar
        );

ALTER TABLE t_weeks ADD CONSTRAINT week_id_pk PRIMARY KEY ( week_id );

CREATE TABLE t_years
    AS
        ( SELECT DISTINCT
            to_number(to_char(end_of_cal_year, 'yyyy')
                      || to_char(end_of_cal_year, 'MM')
                      || to_char(end_of_cal_year, 'DD')
                      || '01')    AS year_id,
            calendar_year,
            days_in_cal_year,
            beg_of_cal_year,
            end_of_cal_year,
            'iso'       AS type
        FROM
            sa_calendar
        UNION ALL
        SELECT
            to_number(to_char(MAX(end_of_cal_quarter), 'yyyy')
                      || to_char(MAX(end_of_cal_quarter), 'MM')
                      || to_char(MAX(end_of_cal_quarter), 'DD')
                      || '02')                                                           AS year_id,
            calendar_year,
            trunc(MAX(end_of_cal_quarter) - MIN(beg_of_cal_quarter))           AS days_in_cal_quarter,
            MIN(beg_of_cal_quarter)                                            AS beg_of_cal_year,
            MAX(end_of_cal_quarter)                                            AS end_of_cal_year,
            'fin'                                                              AS type
        FROM
            (
                SELECT
                    beg_of_cal_quarter,
                    end_of_cal_quarter,
                    to_char(end_of_cal_quarter, 'YYYY') AS calendar_year
                FROM
                    t_quarters
                WHERE
                    type = 'fin'
            ) temp
        GROUP BY
            calendar_year,
            'fin'
        );

ALTER TABLE t_years ADD CONSTRAINT year_id_pk PRIMARY KEY ( year_id );

CREATE TABLE t_months
    AS
        ( SELECT DISTINCT
            to_number(to_char(end_of_cal_month, 'yyyy')
                      || to_char(end_of_cal_month, 'MM')
                      || to_char(end_of_cal_month, 'DD')
                      || '01')                  AS month_id,
            calendar_month_number,
            days_in_cal_month,
            trunc(time_id, 'mm')      AS beg_of_cal_month,
            end_of_cal_month,
            calendar_month_name,
            'iso'                     AS type
        FROM
            sa_calendar
        UNION ALL
        SELECT
            to_number(to_char(MAX(m.end_of_cal_month), 'yyyy')
                      || to_char(MAX(m.end_of_cal_month), 'MM')
                      || to_char(MAX(m.end_of_cal_month), 'DD')
                      || '02')                                                                        AS month_id,
            to_char(MAX(m.end_of_cal_month), 'MM')                                          AS calendar_month_number,
            to_char(trunc(MAX(m.end_of_cal_month) - MIN(m.week_beg_date)))                  AS days_in_cal_month,
            MIN(m.week_beg_date)                                                            AS beg_of_cal_month,
            MAX(m.end_of_cal_month)                                                         AS end_of_cal_month,
            m.calendar_month_name,
            'fin'                                                                           AS type
        FROM
            (
                SELECT
                    trunc(time_id, 'DAY')                     AS week_beg_date,
                    to_char(week_ending_date, 'YYYY')         AS calendar_year,
                    to_char(week_ending_date, 'MM')           AS calendar_month_number,
                    week_ending_date                          AS end_of_cal_month,
                    to_char(week_ending_date, 'FMMonth')      AS calendar_month_name,
                    'fin'                                     AS type
                FROM
                    sa_calendar
            ) m
        GROUP BY
            m.calendar_month_name,
            calendar_year,
            'fin'
        );

ALTER TABLE t_months ADD CONSTRAINT month_id_pk PRIMARY KEY ( month_id );

CREATE TABLE t_quarters
    AS
        ( SELECT DISTINCT
            to_number(to_char(end_of_cal_quarter, 'yyyy')
                      || to_char(end_of_cal_quarter, 'MM')
                      || to_char(end_of_cal_quarter, 'DD')
                      || '01')    AS quarter_id,
            days_in_cal_quarter,
            beg_of_cal_quarter,
            end_of_cal_quarter,
            calendar_quarter_number,
            'iso'       AS type
        FROM
            sa_calendar
        UNION ALL
        SELECT
            to_number(to_char(MAX(end_of_cal_month), 'yyyy')
                      || to_char(MAX(end_of_cal_month), 'MM')
                      || to_char(MAX(end_of_cal_month), 'DD')
                      || '02')                                                       AS quarter_id,
            trunc(MAX(end_of_cal_month) - MIN(end_of_cal_month))           AS days_in_cal_quarter,
            MIN(beg_of_cal_month)                                          AS beg_of_cal_quarter,
            MAX(end_of_cal_month)                                          AS end_of_cal_quarter,
            q                                                              AS calendar_quarter_number,
            'fin'                                                          AS type
        FROM
            (
                SELECT
                    beg_of_cal_month,
                    end_of_cal_month,
                    to_char(end_of_cal_month, 'Q')       AS q,
                    to_char(end_of_cal_month, 'YYYY')    AS calendar_year
                FROM
                    t_months
                WHERE
                    type = 'fin'
            ) temp
        GROUP BY
            q,
            calendar_year,
            'fin'
        );

ALTER TABLE t_quarters ADD CONSTRAINT quarter_id_pk PRIMARY KEY ( quarter_id );

CREATE TABLE dim_DATE
    AS
        ( SELECT
            t_days.time_id                        time_id,
            t_days.day_name                       day_name,
            t_days.day_number_in_week             day_number_in_week_iso,
            t_days.day_number_in_month            day_number_in_month_iso,
            t_days.day_number_in_year             day_number_in_year_iso,
            t_weeks.week_id                       week_id,
            t_weeks.week_beg_date                 week_beg_date,
            t_weeks.week_ending_date              week_ending_date,
            t_months.month_id                     month_id_iso,
            t_months.calendar_month_number        calendar_month_number_iso,
            t_months.days_in_cal_month            days_in_cal_month_iso,
            t_months.beg_of_cal_month             beg_of_cal_month_iso,
            t_months.end_of_cal_month             end_of_cal_month_iso,
            t_months.calendar_month_name          calendar_month_name_iso,
            m.month_id                            month_id_fin,
            m.calendar_month_number               calendar_month_number_fin,
            m.days_in_cal_month                   days_in_cal_month_fin,
            m.beg_of_cal_month                    beg_of_cal_month_fin,
            m.end_of_cal_month                    end_of_cal_month_fin,
            m.calendar_month_name                 calendar_month_name_fin,
            t_quarters.quarter_id                 quarter_id_iso,
            t_quarters.days_in_cal_quarter        days_in_cal_quarter_iso,
            t_quarters.beg_of_cal_quarter         beg_of_cal_quarter_iso,
            t_quarters.end_of_cal_quarter         end_of_cal_quarter_iso,
            t_quarters.calendar_quarter_number    calendar_quarter_number_iso,
            q.quarter_id                          quarter_id_fin,
            q.days_in_cal_quarter                 days_in_cal_quarter_fin,
            q.beg_of_cal_quarter                  beg_of_cal_quarter_fin,
            q.end_of_cal_quarter                  end_of_cal_quarter_fin,
            q.calendar_quarter_number             calendar_quarter_number_fin,
            t_years.year_id                       year_id_iso,
            t_years.calendar_year                 calendar_year_iso,
            t_years.days_in_cal_year              days_in_cal_year_iso,
            t_years.beg_of_cal_year               beg_of_cal_year_iso,
            t_years.end_of_cal_year               end_of_cal_year_iso,
            y.year_id                             year_id_fin,
            y.calendar_year                       calendar_year_fin,
            y.days_in_cal_year                    days_in_cal_year_fin,
            y.beg_of_cal_year                     beg_of_cal_year_fin,
            y.end_of_cal_year                     end_of_cal_year_fin
        FROM
                 t_days
            INNER JOIN t_weeks ON t_days.time_id BETWEEN week_beg_date AND week_ending_date
            INNER JOIN t_months ON t_days.time_id BETWEEN beg_of_cal_month AND end_of_cal_month
                                   AND type = 'iso'
            INNER JOIN t_months    m ON t_days.time_id BETWEEN m.beg_of_cal_month AND m.end_of_cal_month
                                     AND m.type = 'fin'
            INNER JOIN t_quarters ON t_days.time_id BETWEEN t_quarters.beg_of_cal_quarter AND t_quarters.end_of_cal_quarter
                                     AND t_quarters.type = 'iso'
            INNER JOIN t_quarters  q ON t_days.time_id BETWEEN q.beg_of_cal_quarter AND q.end_of_cal_quarter
                                       AND q.type = 'fin'
            INNER JOIN t_years ON t_days.time_id BETWEEN t_years.beg_of_cal_year AND t_years.end_of_cal_year
                                  AND t_years.type = 'iso'
            INNER JOIN t_years     y ON t_days.time_id BETWEEN y.beg_of_cal_year AND y.end_of_cal_year
                                    AND y.type = 'fin'
        );

        
ALTER TABLE DIM_DATE
 ADD CONSTRAINT DIM_ID_PK
 PRIMARY KEY (TIME_ID);