const
	FILEPATH = 'HexGeoIP.dat';
	//MAX_RECORD_LENGTH = 8;//4;
	STANDARD_RECORD_LENGTH = 6;//3;
	COUNTRY_BEGIN = 16776960;
var
	CountryCodes: array of string;
	CountryNames: array of string;
	File: string;

//Converts IP to longword
function IPToLong(IP: string): longword;
var
	temp: array of string;
begin
	temp := Explode(IP, '.');
	Result := StrToInt(temp[0]) shl 24 + StrToInt(temp[1]) shl 16 + StrToInt(temp[2]) shl 8 + StrToInt(temp[3]);
end;


//From GeoIP API
function SeekRecord(IPNum: Cardinal): Cardinal;
var
   depth: shortint;
   offset: Cardinal;
   i,j: byte;
   x: array[0..1] of Cardinal;
   //y: Cardinal;
   buf: string;
begin
	offset := 0;
	for depth:=31 downto 0 do begin
		buf := Copy(File, 2 * STANDARD_RECORD_LENGTH * offset+1, 2 * STANDARD_RECORD_LENGTH+1);
		for i := 0 to 1 do begin
			x[i] := 0;
			for j := 0 to STANDARD_RECORD_LENGTH-1 do begin
			x[i] := x[i] + StrToInt('$'+buf[i*STANDARD_RECORD_LENGTH+j+1]+buf[i*STANDARD_RECORD_LENGTH+j+2]) shl (j*4);
			j := j + 1;
			end;
		end;
		if (IPNum and (1 shl depth)) <> 0 then begin
			if x[1] >= COUNTRY_BEGIN then begin
				Result := x[1];
				Exit;
			end else begin
				Offset := x[1];
			end;
		end else begin
			if x[0] >= COUNTRY_BEGIN then begin
				Result := x[0];
				Exit;
			end else begin
				Offset := x[0];
			end;
		end;
	end;
	Result := COUNTRY_BEGIN;
end;

//Read the file and fill the IP array with it's data.
procedure InitializeGeoIP();
begin
	if FileExists(FILEPATH) then begin
		File := ReadFile(FILEPATH);
		CountryCodes := ['--','AP','EU','AD','AE','AF','AG','AI','AL','AM','AN','AO','AQ','AR','AS','AT','AU','AW','AZ','BA','BB','BD','BE','BF','BG','BH','BI','BJ','BM','BN','BO','BR','BS','BT','BV','BW','BY','BZ','CA','CC','CD','CF','CG','CH','CI','CK','CL','CM','CN','CO','CR','CU','CV','CX','CY','CZ','DE','DJ','DK','DM','DO','DZ','EC','EE','EG','EH','ER','ES','ET','FI','FJ','FK','FM','FO','FR','FX','GA','GB','GD','GE','GF','GH','GI','GL','GM','GN','GP','GQ','GR','GS','GT','GU','GW',
						 'GY','HK','HM','HN','HR','HT','HU','ID','IE','IL','IN','IO','IQ','IR','IS','IT','JM','JO','JP','KE','KG','KH','KI','KM','KN','KP','KR','KW','KY','KZ','LA','LB','LC','LI','LK','LR','LS','LT','LU','LV','LY','MA','MC','MD','MG','MH','MK','ML','MM','MN','MO','MP','MQ','MR','MS','MT','MU','MV','MW','MX','MY','MZ','NA','NC','NE','NF','NG','NI','NL','NO','NP','NR','NU','NZ','OM','PA','PE','PF','PG','PH','PK','PL','PM','PN','PR','PS','PT','PW','PY','QA','RE','RO','RU',
						 'RW','SA','SB','SC','SD','SE','SG','SH','SI','SJ','SK','SL','SM','SN','SO','SR','ST','SV','SY','SZ','TC','TD','TF','TG','TH','TJ','TK','TM','TN','TO','TL','TR','TT','TV','TW','TZ','UA','UG','UM','US','UY','UZ','VA','VC','VE','VG','VI','VN','VU','WF','WS','YE','YT','RS','ZA','ZM','ME','ZW','A1','A2','O1','AX','GG','IM','JE','BL','MF'];
		CountryNames := ['N/A','Asia/Pacific Region','Europe','Andorra','United Arab Emirates','Afghanistan','Antigua and Barbuda','Anguilla','Albania','Armenia','Netherlands Antilles','Angola','Antarctica','Argentina','American Samoa','Austria','Australia','Aruba','Azerbaijan','Bosnia and Herzegovina','Barbados','Bangladesh','Belgium','Burkina Faso','Bulgaria','Bahrain','Burundi','Benin','Bermuda','Brunei Darussalam','Bolivia','Brazil','Bahamas','Bhutan','Bouvet Island','Botswana',
						 'Belarus','Belize','Canada','Cocos (Keeling) Islands','Congo, The Democratic Republic of the','Central African Republic','Congo','Switzerland','Cote D''Ivoire','Cook Islands','Chile','Cameroon','China','Colombia','Costa Rica','Cuba','Cape Verde','Christmas Island','Cyprus','Czech Republic','Germany','Djibouti','Denmark','Dominica','Dominican Republic','Algeria','Ecuador','Estonia','Egypt','Western Sahara','Eritrea','Spain','Ethiopia','Finland','Fiji',
						 'Falkland Islands (Malvinas)','Micronesia, Federated States of','Faroe Islands','France','France, Metropolitan','Gabon','United Kingdom','Grenada','Georgia','French Guiana','Ghana','Gibraltar','Greenland','Gambia','Guinea','Guadeloupe','Equatorial Guinea','Greece','South Georgia and the South Sandwich Islands','Guatemala','Guam','Guinea-Bissau','Guyana','Hong Kong','Heard Island and McDonald Islands','Honduras','Croatia','Haiti','Hungary','Indonesia','Ireland',
						 'Israel','India','British Indian Ocean Territory','Iraq','Iran, Islamic Republic of','Iceland','Italy','Jamaica','Jordan','Japan','Kenya','Kyrgyzstan','Cambodia','Kiribati','Comoros','Saint Kitts and Nevis','Korea, Democratic People''s Republic of','Korea, Republic of','Kuwait','Cayman Islands','Kazakstan','Lao People''s Democratic Republic','Lebanon','Saint Lucia','Liechtenstein','Sri Lanka','Liberia','Lesotho','Lithuania','Luxembourg','Latvia',
						 'Libyan Arab Jamahiriya','Morocco','Monaco','Moldova, Republic of','Madagascar','Marshall Islands','Macedonia, the Former Yugoslav Republic of','Mali','Myanmar','Mongolia','Macao','Northern Mariana Islands','Martinique','Mauritania','Montserrat','Malta','Mauritius','Maldives','Malawi','Mexico','Malaysia','Mozambique','Namibia','New Caledonia','Niger','Norfolk Island','Nigeria','Nicaragua','Netherlands','Norway','Nepal','Nauru','Niue','New Zealand','Oman',
						 'Panama','Peru','French Polynesia','Papua New Guinea','Philippines','Pakistan','Poland','Saint Pierre and Miquelon','Pitcairn','Puerto Rico','Palestinian Territory, Occupied','Portugal','Palau','Paraguay','Qatar','Reunion','Romania','Russian Federation','Rwanda','Saudi Arabia','Solomon Islands','Seychelles','Sudan','Sweden','Singapore','Saint Helena','Slovenia','Svalbard and Jan Mayen','Slovakia','Sierra Leone','San Marino','Senegal','Somalia','Suriname',
						 'Sao Tome and Principe','El Salvador','Syrian Arab Republic','Swaziland','Turks and Caicos Islands','Chad','French Southern Territories','Togo','Thailand','Tajikistan','Tokelau','Turkmenistan','Tunisia','Tonga','Timor-Leste','Turkey','Trinidad and Tobago','Tuvalu','Taiwan','Tanzania, United Republic of','Ukraine','Uganda','United States Minor Outlying Islands','United States','Uruguay','Uzbekistan','Holy See (Vatican City State)',
						 'Saint Vincent and the Grenadines','Venezuela','Virgin Islands, British','Virgin Islands, U.S.','Vietnam','Vanuatu','Wallis and Futuna','Samoa','Yemen','Mayotte','Serbia','South Africa','Zambia','Montenegro','Zimbabwe','Anonymous Proxy','Satellite Provider','Other','Aland Islands','Guernsey','Isle of Man','Jersey','Saint Barthelemy','Saint Martin']
	end else
		Debug(0, '[ERROR]: '+FILEPATH+' not found!');
end;

function GetCountryID(IP: string): byte;
begin
	Result := SeekRecord(IPToLong(IP)) - COUNTRY_BEGIN;
end;

function GetCountryCode(IP: string): string;
begin
	Result := CountryCodes[GetCountryID(IP)];
end;

function GetCountryName(IP: string): string;
begin
	Result := CountryNames[GetCountryID(IP)];
end;
