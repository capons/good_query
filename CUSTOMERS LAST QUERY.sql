




1) CUSTOMERS GOOD QUERY 

QUERY FUNCTIONS



--------------------------------
-------------------------------
function get_upcoming_date 
param store_id , lati , langi


RETURN (SELECT upcoming_date_.schedule_date FROM (SELECT upcoming_date.schedule_date FROM (SELECT MIN(distance_count.distance), distance_count.schedule_date
FROM (SELECT clout_v1_3.stores.latitude, clout_v1_3.stores.longitude, clout_v1_3.store_schedule.schedule_date, SQRT(
    POW(69.1 * (clout_v1_3.stores.latitude - lati), 2) +
    POW(69.1 * (langi - clout_v1_3.stores.longitude) * COS(clout_v1_3.stores.latitude / 57.3), 2)) AS distance
FROM clout_v1_3.stores
LEFT JOIN clout_v1_3.store_schedule ON clout_v1_3.stores.id = clout_v1_3.store_schedule._store_id WHERE clout_v1_3.stores.id=store_id) AS distance_count) AS upcoming_date) AS upcoming_date_)


function store_distance
param lati,longi,store_id

RETURN (SELECT distance
FROM (SELECT clout_v1_3.stores.latitude, clout_v1_3.stores.longitude, SQRT(
    POW(69.1 * (clout_v1_3.stores.latitude - lati), 2) +
    POW(69.1 * (langi - clout_v1_3.stores.longitude) * COS(clout_v1_3.stores.latitude / 57.3), 2)) AS distance
FROM clout_v1_3.stores where clout_v1_3.stores.id =store_id) AS distance_count)

function other_reserv
param store_id,user_id

RETURN (SELECT count(*) FROM clout_v1_3.store_schedule  where clout_v1_3.store_schedule._user_id=user_id and clout_v1_3.store_schedule._store_id <> store_id)

function store_last_transaction
param store_id

RETURN (SELECT max(clout_v1_3cron.transactions.start_date) FROM clout_v1_3cron.transactions WHERE clout_v1_3cron.transactions._store_id=store_id)


function last_activity
param store_id user_id

RETURN (SELECT max(clout_v1_3.user_geo_tracking.tracking_time) FROM `user_geo_tracking` WHERE clout_v1_3.user_geo_tracking._checkin_store_id = store_id and clout_v1_3.user_geo_tracking._user_id = user_id)

function priority
param store_id

RETURN  (SELECT  clout_v1_3.store_schedule.schedule_date
FROM    clout_v1_3.store_schedule
WHERE   clout_v1_3.store_schedule.schedule_date BETWEEN NOW() - INTERVAL 1 DAY AND NOW() and clout_v1_3.store_schedule._store_id = store_id)













SELECT _store.id, score_by_store.store_id,_user.id as user_id, CONCAT(_user.first_name, ' ',_user.last_name)as name, score_by_store.total_score as score, score_by_store.my_store_spending_lifetime as in_store_spending,
score_by_store.my_direct_competitors_spending_lifetime as competitor_spending,
score_by_store.my_category_spending_lifetime as category_spending,
score_by_store.related_categories_spending_lifetime as related_spending,
(SELECT SUM(clout_v1_3cron.transactions_raw.amount) FROM clout_v1_3cron.transactions_raw where clout_v1_3cron.transactions_raw._user_id = _user.id) as overall_spending,
datatab_user_data.total_linked_accounts as linked_accounts,

last_activity(_store.id,_user.id) as activity,

_user.city,_user.state,_user.zipcode as zip, _user.country_code as country,_user.gender, SUBSTRING_INDEX(DATEDIFF(CURRENT_DATE, STR_TO_DATE(_user.birthday, '%Y-%m-%d'))/365, '.', 1)   AS age,
p_custom_cat.category_label as custom_label,
s_schedule.special_request as notes,
(SELECT count(*) FROM clout_v1_3.referrals where clout_v1_3.referrals._user_id = _user.id )as network,
(SELECT count(*) FROM clout_v1_3msg.message_invites where clout_v1_3msg.message_invites._user_id = _user.id) as invites,

get_upcoming_date(_store.id,g_tracking.latitude,g_tracking.longitude) as upcoming,
_store.latitude as lati,
_store.longitude as longi,
_DISTANCE_                                                           //store_distance(_LATI_,_LONGI_,_store.id) as distance_store,   //function display customer distance to store


DATE_FORMAT(s_schedule.schedule_date,'%r') as time,
promotion.promotion_type as type,
s_schedule.number_in_party as size,
c_transaction.status,

other_reserv(_store.id,_user.id) as other_reservations,

CONCAT(g_tracking.tracking_time,'|',g_tracking.source) as last_checkins,
(SELECT count(*) FROM clout_v1_3.user_geo_tracking as _g_tracking WHERE _g_tracking._user_id = _user.id and _g_tracking._checkin_store_id = _store.id ) as past_checkins,
(SELECT count(*) FROM clout_v1_3cron.transactions_raw as cus_transaction WHERE  cus_transaction._user_id = _user.id)as transactions,
(SELECT count(*) FROM clout_v1_3.reviews as _review where _review._user_id = _user.id and _review._store_id = _store.id) as reviews,
(SELECT count(*) FROM clout_v1_3.store_favorites as s_favorites where s_favorites._user_id = _user.id and s_favorites._store_id = _store.id) as favorited,
(SELECT count(*) FROM clout_v1_3msg.message_invites as cus_invites where cus_invites._user_id = _user.id and cus_invites.referral_status = 'accepted') as network_size,
s_schedule.reservation_status as reservation,
s_schedule.schedule_date,
_store.name as store_name,
_store.address_line_1 as store_address,
_store._country_code as store_country,
_store.city as store_city,
_user.photo_url,

store_last_transaction(_store.id) as store_last_transaction,

FROM clout_v1_3.users as _user
                            INNER JOIN clout_v1_3cron.cacheview__store_score_by_store as score_by_store ON score_by_store.user_id = _user.id
                            INNER JOIN clout_v1_3cron.datatable__user_data as datatab_user_data ON datatab_user_data.user_id = _user.id
                            LEFT JOIN clout_v1_3.store_schedule as s_schedule ON s_schedule._store_id = score_by_store.store_id
                            LEFT JOIN clout_v1_3.promotions_custom_categories as p_custom_cat ON p_custom_cat.user_id = _user.id
                            LEFT JOIN clout_v1_3cron.commissions_transactions as c_transaction ON c_transaction._store_id = score_by_store.store_id
                            INNER JOIN clout_v1_3.stores as _store ON _store.id = score_by_store.store_id
                            LEFT JOIN clout_v1_3cron.promotions as promotion ON promotion.owner_id = _store.id AND promotion.owner_type='store'
                            LEFT JOIN clout_v1_3.user_geo_tracking as g_tracking ON g_tracking._user_id = _user.id and g_tracking._checkin_store_id = _store.id 
                            _WHERE_
                            


                            HAVING distance_store < 80          //in distance 50 miles                //ADD IF WE WHANT TO DISPLAY Stores in 50 miles distance





   QUERY TO DISPLAY IN MYSQL



   SELECT _store.id, score_by_store.store_id,_user.id as user_id, CONCAT(_user.first_name, ' ',_user.last_name)as name, score_by_store.total_score as score, score_by_store.my_store_spending_lifetime as in_store_spending,
score_by_store.my_direct_competitors_spending_lifetime as competitor_spending,
score_by_store.my_category_spending_lifetime as category_spending,
score_by_store.related_categories_spending_lifetime as related_spending,
(SELECT SUM(clout_v1_3cron.transactions_raw.amount) FROM clout_v1_3cron.transactions_raw where clout_v1_3cron.transactions_raw._user_id = _user.id) as overall_spending,
datatab_user_data.total_linked_accounts as linked_accounts,

last_activity(_store.id,_user.id) as activity,

_user.city,_user.state,_user.zipcode as zip, _user.country_code as country,_user.gender, SUBSTRING_INDEX(DATEDIFF(CURRENT_DATE, STR_TO_DATE(_user.birthday, '%Y-%m-%d'))/365, '.', 1)   AS age,
p_custom_cat.category_label as custom_label,
s_schedule.special_request as notes,
(SELECT count(*) FROM clout_v1_3.referrals where clout_v1_3.referrals._user_id = _user.id )as network,
(SELECT count(*) FROM clout_v1_3msg.message_invites where clout_v1_3msg.message_invites._user_id = _user.id) as invites,

get_upcoming_date(_store.id,g_tracking.latitude,g_tracking.longitude) as upcoming,

store_distance(_store.latitude,_store.longitude,_store.id) as distance_store,

DATE_FORMAT(s_schedule.schedule_date,'%r') as time,
promotion.promotion_type as type,
s_schedule.number_in_party as size,
c_transaction.status,

other_reserv(_store.id,_user.id) as other_reservations,


CONCAT(g_tracking.tracking_time,'|',g_tracking.source) as last_checkins,
(SELECT count(*) FROM clout_v1_3.user_geo_tracking as _g_tracking WHERE _g_tracking._user_id = _user.id and _g_tracking._checkin_store_id = _store.id ) as past_checkins,
(SELECT count(*) FROM clout_v1_3cron.transactions_raw as cus_transaction WHERE  cus_transaction._user_id = _user.id)as transactions,
(SELECT count(*) FROM clout_v1_3.reviews as _review where _review._user_id = _user.id and _review._store_id = _store.id) as reviews,
(SELECT count(*) FROM clout_v1_3.store_favorites as s_favorites where s_favorites._user_id = _user.id and s_favorites._store_id = _store.id) as favorited,
(SELECT count(*) FROM clout_v1_3msg.message_invites as cus_invites where cus_invites._user_id = _user.id and cus_invites.referral_status = 'accepted') as network_size,
s_schedule.reservation_status as reservation,
s_schedule.schedule_date,
_store.name as store_name,
_store.address_line_1 as store_address,
_store._country_code as store_country,
_store.latitude as lati,
_store.longitude as longi,
_store.city as store_city,
_user.photo_url,

store_last_transaction(_store.id) as store_last_transaction


FROM clout_v1_3.users as _user
                            INNER JOIN clout_v1_3cron.cacheview__store_score_by_store as score_by_store ON score_by_store.user_id = _user.id
                            INNER JOIN clout_v1_3cron.datatable__user_data as datatab_user_data ON datatab_user_data.user_id = _user.id
                            LEFT JOIN clout_v1_3.store_schedule as s_schedule ON s_schedule._store_id = score_by_store.store_id
                            LEFT JOIN clout_v1_3.promotions_custom_categories as p_custom_cat ON p_custom_cat.user_id = _user.id
                            LEFT JOIN clout_v1_3cron.commissions_transactions as c_transaction ON c_transaction._store_id = score_by_store.store_id
                            INNER JOIN clout_v1_3.stores as _store ON _store.id = score_by_store.store_id
                            LEFT JOIN clout_v1_3cron.promotions as promotion ON promotion.owner_id = _store.id AND promotion.owner_type='store'
                            LEFT JOIN clout_v1_3.user_geo_tracking as g_tracking ON g_tracking._user_id = _user.id and g_tracking._checkin_store_id = _store.id 
                            HAVING distance_store < 80









  ЗАПРОС С Priority 

SELECT  clout_v1_3.store_schedule.schedule_date
FROM    clout_v1_3.store_schedule
WHERE   clout_v1_3.store_schedule.schedule_date BETWEEN NOW() - INTERVAL 200 DAY AND NOW() and clout_v1_3.store_schedule._store_id = 1







    SELECT _store.id, score_by_store.store_id,_user.id as user_id, CONCAT(_user.first_name, ' ',_user.last_name)as name, score_by_store.total_score as score, score_by_store.my_store_spending_lifetime as in_store_spending,
score_by_store.my_direct_competitors_spending_lifetime as competitor_spending,
score_by_store.my_category_spending_lifetime as category_spending,
score_by_store.related_categories_spending_lifetime as related_spending,
(SELECT SUM(clout_v1_3cron.transactions_raw.amount) FROM clout_v1_3cron.transactions_raw where clout_v1_3cron.transactions_raw._user_id = _user.id) as overall_spending,
datatab_user_data.total_linked_accounts as linked_accounts,

last_activity(_store.id,_user.id) as activity,

_user.city,_user.state,_user.zipcode as zip, _user.country_code as country,_user.gender, SUBSTRING_INDEX(DATEDIFF(CURRENT_DATE, STR_TO_DATE(_user.birthday, '%Y-%m-%d'))/365, '.', 1)   AS age,
p_custom_cat.category_label as custom_label,
s_schedule.special_request as notes,
(SELECT count(*) FROM clout_v1_3.referrals where clout_v1_3.referrals._user_id = _user.id )as network,
(SELECT count(*) FROM clout_v1_3msg.message_invites where clout_v1_3msg.message_invites._user_id = _user.id) as invites,

get_upcoming_date(_store.id,g_tracking.latitude,g_tracking.longitude) as upcoming,

store_distance(_store.latitude,_store.longitude,_store.id) as distance_store,

DATE_FORMAT(s_schedule.schedule_date,'%r') as time,
promotion.promotion_type as type,
s_schedule.number_in_party as size,
c_transaction.status,

other_reserv(_store.id,_user.id) as other_reservations,


CONCAT(g_tracking.tracking_time,'|',g_tracking.source) as last_checkins,
(SELECT count(*) FROM clout_v1_3.user_geo_tracking as _g_tracking WHERE _g_tracking._user_id = _user.id and _g_tracking._checkin_store_id = _store.id ) as past_checkins,
(SELECT count(*) FROM clout_v1_3cron.transactions_raw as cus_transaction WHERE  cus_transaction._user_id = _user.id)as transactions,
(SELECT count(*) FROM clout_v1_3.reviews as _review where _review._user_id = _user.id and _review._store_id = _store.id) as reviews,
(SELECT count(*) FROM clout_v1_3.store_favorites as s_favorites where s_favorites._user_id = _user.id and s_favorites._store_id = _store.id) as favorited,
(SELECT count(*) FROM clout_v1_3msg.message_invites as cus_invites where cus_invites._user_id = _user.id and cus_invites.referral_status = 'accepted') as network_size,
s_schedule.reservation_status as reservation,
s_schedule.schedule_date,
_store.name as store_name,
_store.address_line_1 as store_address,
_store._country_code as store_country,
_store.latitude as lati,
_store.longitude as longi,
_store.city as store_city,
_user.photo_url,
priority(_store.id) as priority,

store_last_transaction(_store.id) as store_last_transaction


FROM clout_v1_3.users as _user
                            INNER JOIN clout_v1_3cron.cacheview__store_score_by_store as score_by_store ON score_by_store.user_id = _user.id
                            INNER JOIN clout_v1_3cron.datatable__user_data as datatab_user_data ON datatab_user_data.user_id = _user.id
                            LEFT JOIN clout_v1_3.store_schedule as s_schedule ON s_schedule._store_id = score_by_store.store_id
                            LEFT JOIN clout_v1_3.promotions_custom_categories as p_custom_cat ON p_custom_cat.user_id = _user.id
                            LEFT JOIN clout_v1_3cron.commissions_transactions as c_transaction ON c_transaction._store_id = score_by_store.store_id
                            INNER JOIN clout_v1_3.stores as _store ON _store.id = score_by_store.store_id
                            LEFT JOIN clout_v1_3cron.promotions as promotion ON promotion.owner_id = _store.id AND promotion.owner_type='store'
                            LEFT JOIN clout_v1_3.user_geo_tracking as g_tracking ON g_tracking._user_id = _user.id and g_tracking._checkin_store_id = _store.id 
                            ORDER BY priority DESC