import 'package:bookstore_app/Restitutor_custom/dao_custom.dart';
import 'package:bookstore_app/model/customer.dart';
import 'package:bookstore_app/model/employee.dart';
import 'package:bookstore_app/model/login_history.dart';
import 'package:bookstore_app/model/sale/purchase_item.dart';
import 'package:bookstore_app/mv/assembly.dart';
import 'package:bookstore_app/config.dart' as config;


//  DbSetting
/*
  Create: 12/11/2025 , Creator: zero
    Update log: 
    12/11/2025 14:31, 'Point 1, 최초 업데이트 및 기본 정보 추가', Creator: zero
    12/12/2025 11:16, 'Point 2, 필요 없는 데이터 삭제', Creator: zero
    12/12/2025 14:31, 'Point 3, data_set.dart에 있던 데이터를 가져오고 TableBatch를 이용하여 데이터 세팅', Creator: zero
    12/12/2025 22:00, 'Point 4, 회원관련 시나리오 수정, purchase, purchaseitem을 multibatch로 묶음', Creator: zero

  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: insert data into db
*/
class DbSetting {

  final String dbName = '${config.kDBName}${config.kDBFileExt}';
  final int dVersion = config.kVersion;

  Future<void> svInitDB() async {
    TableBatch manufacturerBatch = TableBatch(
      tableName: 'Manufacturer',
      rows: [
        {'mName': 'Nike'},
        {'mName': 'NewBalance'},
      ],
    );
    TableBatch imgBatch = TableBatch(
      tableName: 'ProductImage',
      rows: [
        {
          'pbid': 1,
          'imagePath':
              '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Black_01.png',
        },
        {
          'pbid': 1,
          'imagePath':
              '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Black_02.png',
        },
        {
          'pbid': 1,
          'imagePath':
              '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Black_03.png',
        },

        {
          'pbid': 2,
          'imagePath':
              '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Gray_01.png',
        },
        {
          'pbid': 2,
          'imagePath':
              '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Gray_02.png',
        },
        {
          'pbid': 2,
          'imagePath':
              '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Gray_03.png',
        },

        {
          'pbid': 3,
          'imagePath':
              '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_White_01.png',
        },
        {
          'pbid': 3,
          'imagePath':
              '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_White_02.png',
        },
        {
          'pbid': 3,
          'imagePath':
              '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_White_03.png',
        },

        {
          'pbid': 4,
          'imagePath':
              '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Black_01.avif',
        },
        {
          'pbid': 4,
          'imagePath':
              '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Black_02.avif',
        },
        {
          'pbid': 4,
          'imagePath':
              '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Black_03.avif',
        },

        {
          'pbid': 5,
          'imagePath':
              '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Gray_01.avif',
        },
        {
          'pbid': 5,
          'imagePath':
              '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Gray_02.avif',
        },
        {
          'pbid': 5,
          'imagePath':
              '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Gray_03.avif',
        },

        {
          'pbid': 6,
          'imagePath':
              '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_White_01.avif',
        },
        {
          'pbid': 6,
          'imagePath':
              '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_White_02.avif',
        },
        {
          'pbid': 6,
          'imagePath':
              '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_White_03.avif',
        },

        {
          'pbid': 7,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_01.avif',
        },
        {
          'pbid': 7,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_02.avif',
        },
        {
          'pbid': 7,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_03.avif',
        },

        {
          'pbid': 8,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_01.avif',
        },
        {
          'pbid': 8,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_02.avif',
        },
        {
          'pbid': 8,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_03.avif',
        },

        {
          'pbid': 9,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_01.avif',
        },
        {
          'pbid': 9,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_02.avif',
        },
        {
          'pbid': 9,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_03.avif',
        },

        {
          'pbid': 10,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_01.avif',
        },
        {
          'pbid': 10,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_02.avif',
        },
        {
          'pbid': 10,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_03.avif',
        },

        {
          'pbid': 11,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_01.avif',
        },
        {
          'pbid': 11,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_02.avif',
        },
        {
          'pbid': 11,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_03.avif',
        },

        {
          'pbid': 12,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_01.avif',
        },
        {
          'pbid': 12,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_02.avif',
        },
        {
          'pbid': 12,
          'imagePath':
              '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_03.avif',
        },
      ],
    );

    TableBatch productBatch = TableBatch(
      tableName: 'Product',
      rows: [
        {'pbid': 1, 'mfid': 1, 'size': 220, 'basePrice': 100000},
        {'pbid': 1, 'mfid': 1, 'size': 230, 'basePrice': 110000},
        {'pbid': 1, 'mfid': 1, 'size': 240, 'basePrice': 120000},
        {'pbid': 1, 'mfid': 1, 'size': 250, 'basePrice': 130000},
        {'pbid': 1, 'mfid': 1, 'size': 260, 'basePrice': 140000},
        {'pbid': 1, 'mfid': 1, 'size': 270, 'basePrice': 150000},
        {'pbid': 1, 'mfid': 1, 'size': 280, 'basePrice': 160000},

        {'pbid': 2, 'mfid': 1, 'size': 220, 'basePrice': 100500},
        {'pbid': 2, 'mfid': 1, 'size': 230, 'basePrice': 101500},
        {'pbid': 2, 'mfid': 1, 'size': 240, 'basePrice': 102500},
        {'pbid': 2, 'mfid': 1, 'size': 250, 'basePrice': 103500},
        {'pbid': 2, 'mfid': 1, 'size': 260, 'basePrice': 104500},
        {'pbid': 2, 'mfid': 1, 'size': 270, 'basePrice': 105500},
        {'pbid': 2, 'mfid': 1, 'size': 280, 'basePrice': 106500},

        {'pbid': 3, 'mfid': 1, 'size': 220, 'basePrice': 102000},
        {'pbid': 3, 'mfid': 1, 'size': 230, 'basePrice': 102100},
        {'pbid': 3, 'mfid': 1, 'size': 240, 'basePrice': 102200},
        {'pbid': 3, 'mfid': 1, 'size': 250, 'basePrice': 102300},
        {'pbid': 3, 'mfid': 1, 'size': 260, 'basePrice': 102400},
        {'pbid': 3, 'mfid': 1, 'size': 270, 'basePrice': 102500},
        {'pbid': 3, 'mfid': 1, 'size': 280, 'basePrice': 102600},

        {'pbid': 4, 'mfid': 2, 'size': 220, 'basePrice': 180000},
        {'pbid': 4, 'mfid': 2, 'size': 230, 'basePrice': 181000},
        {'pbid': 4, 'mfid': 2, 'size': 240, 'basePrice': 182000},
        {'pbid': 4, 'mfid': 2, 'size': 250, 'basePrice': 183000},
        {'pbid': 4, 'mfid': 2, 'size': 260, 'basePrice': 184000},
        {'pbid': 4, 'mfid': 2, 'size': 270, 'basePrice': 185000},
        {'pbid': 4, 'mfid': 2, 'size': 280, 'basePrice': 186000},

        {'pbid': 5, 'mfid': 2, 'size': 220, 'basePrice': 118000},
        {'pbid': 5, 'mfid': 2, 'size': 230, 'basePrice': 123000},
        {'pbid': 5, 'mfid': 2, 'size': 240, 'basePrice': 128000},
        {'pbid': 5, 'mfid': 2, 'size': 250, 'basePrice': 133000},
        {'pbid': 5, 'mfid': 2, 'size': 260, 'basePrice': 138000},
        {'pbid': 5, 'mfid': 2, 'size': 270, 'basePrice': 143000},
        {'pbid': 5, 'mfid': 2, 'size': 280, 'basePrice': 148000},

        {'pbid': 6, 'mfid': 2, 'size': 220, 'basePrice': 98000},
        {'pbid': 6, 'mfid': 2, 'size': 230, 'basePrice': 99500},
        {'pbid': 6, 'mfid': 2, 'size': 240, 'basePrice': 101000},
        {'pbid': 6, 'mfid': 2, 'size': 250, 'basePrice': 102500},
        {'pbid': 6, 'mfid': 2, 'size': 260, 'basePrice': 104000},
        {'pbid': 6, 'mfid': 2, 'size': 270, 'basePrice': 105500},
        {'pbid': 6, 'mfid': 2, 'size': 280, 'basePrice': 107000},

        {'pbid': 7, 'mfid': 2, 'size': 220, 'basePrice': 102000},
        {'pbid': 7, 'mfid': 2, 'size': 230, 'basePrice': 103000},
        {'pbid': 7, 'mfid': 2, 'size': 240, 'basePrice': 104000},
        {'pbid': 7, 'mfid': 2, 'size': 250, 'basePrice': 105000},
        {'pbid': 7, 'mfid': 2, 'size': 260, 'basePrice': 106000},
        {'pbid': 7, 'mfid': 2, 'size': 270, 'basePrice': 107000},
        {'pbid': 7, 'mfid': 2, 'size': 280, 'basePrice': 108000},

        {'pbid': 8, 'mfid': 2, 'size': 220, 'basePrice': 175000},
        {'pbid': 8, 'mfid': 2, 'size': 230, 'basePrice': 178000},
        {'pbid': 8, 'mfid': 2, 'size': 240, 'basePrice': 181000},
        {'pbid': 8, 'mfid': 2, 'size': 250, 'basePrice': 184000},
        {'pbid': 8, 'mfid': 2, 'size': 260, 'basePrice': 187000},
        {'pbid': 8, 'mfid': 2, 'size': 270, 'basePrice': 190000},
        {'pbid': 8, 'mfid': 2, 'size': 280, 'basePrice': 193000},

        {'pbid': 9, 'mfid': 2, 'size': 220, 'basePrice': 135000},
        {'pbid': 9, 'mfid': 2, 'size': 230, 'basePrice': 140000},
        {'pbid': 9, 'mfid': 2, 'size': 240, 'basePrice': 145000},
        {'pbid': 9, 'mfid': 2, 'size': 250, 'basePrice': 150000},
        {'pbid': 9, 'mfid': 2, 'size': 260, 'basePrice': 155000},
        {'pbid': 9, 'mfid': 2, 'size': 270, 'basePrice': 160000},
        {'pbid': 9, 'mfid': 2, 'size': 280, 'basePrice': 165000},

        {'pbid': 10, 'mfid': 2, 'size': 220, 'basePrice': 112000},
        {'pbid': 10, 'mfid': 2, 'size': 230, 'basePrice': 115000},
        {'pbid': 10, 'mfid': 2, 'size': 240, 'basePrice': 118000},
        {'pbid': 10, 'mfid': 2, 'size': 250, 'basePrice': 121000},
        {'pbid': 10, 'mfid': 2, 'size': 260, 'basePrice': 124000},
        {'pbid': 10, 'mfid': 2, 'size': 270, 'basePrice': 127000},
        {'pbid': 10, 'mfid': 2, 'size': 280, 'basePrice': 130000},

        {'pbid': 11, 'mfid': 2, 'size': 220, 'basePrice': 92000},
        {'pbid': 11, 'mfid': 2, 'size': 230, 'basePrice': 94000},
        {'pbid': 11, 'mfid': 2, 'size': 240, 'basePrice': 96000},
        {'pbid': 11, 'mfid': 2, 'size': 250, 'basePrice': 98000},
        {'pbid': 11, 'mfid': 2, 'size': 260, 'basePrice': 100000},
        {'pbid': 11, 'mfid': 2, 'size': 270, 'basePrice': 102000},
        {'pbid': 11, 'mfid': 2, 'size': 280, 'basePrice': 104000},

        {'pbid': 12, 'mfid': 2, 'size': 220, 'basePrice': 198000},
        {'pbid': 12, 'mfid': 2, 'size': 230, 'basePrice': 202000},
        {'pbid': 12, 'mfid': 2, 'size': 240, 'basePrice': 206000},
        {'pbid': 12, 'mfid': 2, 'size': 250, 'basePrice': 210000},
        {'pbid': 12, 'mfid': 2, 'size': 260, 'basePrice': 214000},
        {'pbid': 12, 'mfid': 2, 'size': 270, 'basePrice': 218000},
        {'pbid': 12, 'mfid': 2, 'size': 280, 'basePrice': 222000},
      ],
    );

    TableBatch productBaseBatch = TableBatch(
      tableName: 'ProductBase',
      rows: [
        {
          'pName': 'U740WN2',
          'pDescription':
              '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.',
          'pColor': 'Black',
          'pGender': 'Unisex',
          'pStatus': '',
          'pCategory': 'Running',
          'pModelNumber': 'NEW009T1',
        },
        {
          'pName': 'U740WN2',
          'pDescription':
              '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.',
          'pColor': 'Gray',
          'pGender': 'Unisex',
          'pStatus': '',
          'pCategory': 'Running',
          'pModelNumber': 'NEW009T1',
        },
        {
          'pName': 'U740WN2',
          'pDescription':
              '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.',
          'pColor': 'White',
          'pGender': 'Unisex',
          'pStatus': '',
          'pCategory': 'Running',
          'pModelNumber': 'NEW009T1',
        },

        {
          'pName': '나이키 샥스 TL',
          'pDescription':
              '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.',
          'pColor': 'Black',
          'pGender': 'Female',
          'pStatus': '',
          'pCategory': 'Running',
          'pModelNumber': 'NIK321E3',
        },
        {
          'pName': '나이키 샥스 TL',
          'pDescription':
              '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.',
          'pColor': 'Gray',
          'pGender': 'Female',
          'pStatus': '',
          'pCategory': 'Running',
          'pModelNumber': 'NIK321E3',
        },
        {
          'pName': '나이키 샥스 TL',
          'pDescription':
              '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.',
          'pColor': 'White',
          'pGender': 'Female',
          'pStatus': '',
          'pCategory': 'Running',
          'pModelNumber': 'NIK321E3',
        },

        {
          'pName': '나이키 에어포스 1',
          'pDescription':
              '편안하고 내구성이 뛰어나며 유행을 타지 않는 고급스러운 스니커즈로, 프리미엄 가죽과 적절하게 배치된 미니 스우시가 클래식 아이템에 세련된 감각을 더해줍니다. 물론 1980년대를 떠올리게 하는 구조와 나이키 에어 쿠셔닝 등 모두가 사랑하는 전설적인 AF1의 룩과 감성은 고스란히 재현했습니다.',
          'pColor': 'Black',
          'pGender': 'Female',
          'pStatus': '',
          'pCategory': 'Sneakers',
          'pModelNumber': 'NISK09UY',
        },
        {
          'pName': '나이키 에어포스 1',
          'pDescription':
              '편안하고 내구성이 뛰어나며 유행을 타지 않는 고급스러운 스니커즈로, 프리미엄 가죽과 적절하게 배치된 미니 스우시가 클래식 아이템에 세련된 감각을 더해줍니다. 물론 1980년대를 떠올리게 하는 구조와 나이키 에어 쿠셔닝 등 모두가 사랑하는 전설적인 AF1의 룩과 감성은 고스란히 재현했습니다.',
          'pColor': 'Gray',
          'pGender': 'Female',
          'pStatus': '',
          'pCategory': 'Sneakers',
          'pModelNumber': 'NISK09UY',
        },
        {
          'pName': '나이키 에어포스 1',
          'pDescription':
              '편안하고 내구성이 뛰어나며 유행을 타지 않는 고급스러운 스니커즈로, 프리미엄 가죽과 적절하게 배치된 미니 스우시가 클래식 아이템에 세련된 감각을 더해줍니다. 물론 1980년대를 떠올리게 하는 구조와 나이키 에어 쿠셔닝 등 모두가 사랑하는 전설적인 AF1의 룩과 감성은 고스란히 재현했습니다.',
          'pColor': 'White',
          'pGender': 'Female',
          'pStatus': '',
          'pCategory': 'Sneakers',
          'pModelNumber': 'NISK09UY',
        },

        {
          'pName': '나이키 페가수스 플러스',
          'pDescription':
              '페가수스 플러스로 차원이 다른 반응성과 쿠셔닝을 느껴보세요. 전체적으로 적용된 초경량 줌X 폼이 일상의 러닝에 높은 에너지 반환력을 제공하기 때문에 활력 있게 달릴 수 있습니다. 그리고 신축성 좋은 플라이니트 갑피가 발을 꼭 맞게 감싸 매끄러운 핏을 선사합니다.',
          'pColor': 'Black',
          'pGender': 'Male',
          'pStatus': '',
          'pCategory': 'Running',
          'pModelNumber': 'NIKTY19Z',
        },
        {
          'pName': '나이키 페가수스 플러스',
          'pDescription':
              '페가수스 플러스로 차원이 다른 반응성과 쿠셔닝을 느껴보세요. 전체적으로 적용된 초경량 줌X 폼이 일상의 러닝에 높은 에너지 반환력을 제공하기 때문에 활력 있게 달릴 수 있습니다. 그리고 신축성 좋은 플라이니트 갑피가 발을 꼭 맞게 감싸 매끄러운 핏을 선사합니다.',
          'pColor': 'Gray',
          'pGender': 'Male',
          'pStatus': '',
          'pCategory': 'Running',
          'pModelNumber': 'NIKTY19Z',
        },
        {
          'pName': '나이키 페가수스 플러스',
          'pDescription':
              '페가수스 플러스로 차원이 다른 반응성과 쿠셔닝을 느껴보세요. 전체적으로 적용된 초경량 줌X 폼이 일상의 러닝에 높은 에너지 반환력을 제공하기 때문에 활력 있게 달릴 수 있습니다. 그리고 신축성 좋은 플라이니트 갑피가 발을 꼭 맞게 감싸 매끄러운 핏을 선사합니다.',
          'pColor': 'White',
          'pGender': 'Male',
          'pStatus': '',
          'pCategory': 'Running',
          'pModelNumber': 'NIKTY19Z',
        },
      ],
    );

    TableBatch employeeBatch = TableBatch(
      tableName: 'Employee',
      rows: [
        {
          'eEmail': 'ma@han.com',
          'ePhoneNumber': '222-6789-5432',
          'eName': '사마의',
          'ePassword': 'qwer1234',
          'eRole': '1',
        },
        {
          'eEmail': 'oiling@han.com',
          'ePhoneNumber': '999-3211-0987',
          'eName': '주유',
          'ePassword': 'qwer1234',
          'eRole': '2',
        },
        {
          'eEmail': 'gongmyeong@han.com',
          'ePhoneNumber': '000-0987-6543',
          'eName': '제갈공명',
          'ePassword': 'qwer1234',
          'eRole': '3',
        },
      ],
    );

    TableBatch customerBatch = TableBatch(
      tableName: 'Customer',
      rows: [
        {
          'cEmail': 'jojo@han.com',
          'cPhoneNumber': '222-9898-1212',
          'cName': '조조',
          'cPassword': 'qwer1234',
        },
        {
          'cEmail': 'handbook@han.com',
          'cPhoneNumber': '999-7676-1987',
          'cName': '손책',
          'cPassword': 'qwer1234',
        },
        {
          'cEmail': 'bigear@han.com',
          'cPhoneNumber': '000-1234-5678',
          'cName': '유비',
          'cPassword': 'qwer1234',
        },
        {
          'cEmail': 'jangryo@han.com',
          'cPhoneNumber': '222-3452-7665',
          'cName': '장료',
          'cPassword': 'qwer1234',
        },
        {
          'cEmail': 'sixhand@han.com',
          'cPhoneNumber': '999-1010-2929',
          'cName': '육손',
          'cPassword': 'qwer1234',
        },
        {
          'cEmail': 'purpledraong@han.com',
          'cPhoneNumber': '000-0987-6543',
          'cName': '조자룡',
          'cPassword': 'qwer1234',
        },
      ],
    );

    TableBatch purchaseBatch = TableBatch(
    tableName: 'Purchase',
    rows: [
      {
        'cid': 1,
        'pickupDate': '2023-12-14 07:20',
        'orderCode': 'orderCode',
        'timeStamp': '2023-12-12 07:20',
      },
      {
        'cid': 1,
        'pickupDate': '2023-12-14 07:20',
        'orderCode': 'orderCode',
        'timeStamp': '2023-12-12 07:20',
      },
      {
        'cid': 1,
        'pickupDate': '2023-12-14 07:20',
        'orderCode': 'orderCode',
        'timeStamp': '2023-12-12 07:20',
      },
      {
        'cid': 1,
        'pickupDate': '2023-12-14 07:20',
        'orderCode': 'orderCode',
        'timeStamp': '2023-12-12 07:20',
      },
      {
        'cid': 1,
        'pickupDate': '2023-12-14 07:20',
        'orderCode': 'orderCode',
        'timeStamp': '2023-12-12 07:20',
      },
    ],
  );

    TableBatch purchaseItemBatch = TableBatch(
      tableName: 'PurchaseItem',
      rows: [
        {'pid': 1, 'pcid': 1, 'pcQuantity': 10, 'pcStatus': '결제 대기'},
        {'pid': 2, 'pcid': 2, 'pcQuantity': 3, 'pcStatus': '결제 대기'},
        {'pid': 3, 'pcid': 2, 'pcQuantity': 6, 'pcStatus': '결제 대기'},
        {'pid': 4, 'pcid': 3, 'pcQuantity': 1, 'pcStatus': '결제 대기'},
        {'pid': 5, 'pcid': 4, 'pcQuantity': 9, 'pcStatus': '결제 대기'},
        {'pid': 6, 'pcid': 5, 'pcQuantity': 11, 'pcStatus': '결제 대기'},
      ],
    );

    TableBatch loginHistoryBatch = TableBatch(
      tableName: 'LoginHistory',
      rows: [
        {
          'cid': 1,
          'loginTime': '2025-12-12 17:05',
          'lStatus': '0',
          'lVersion': 1,
          'lAddress': '강남구',
          'lPaymentMethod': 'KaKaoPay',
        },
        {
          'cid': 2,
          'loginTime': '2025-12-12 19:05',
          'lStatus': '0',
          'lVersion': 1,
          'lAddress': '강남구',
          'lPaymentMethod': 'KaKaoPay',
        },
        {
          'cid': 3,
          'loginTime': '2025-12-12 19:20',
          'lStatus': '0',
          'lVersion': 1,
          'lAddress': '강남구',
          'lPaymentMethod': 'KaKaoPay',
        },
        {
          'cid': 4,
          'loginTime': '2023-12-12 19:20',
          'lStatus': '0',
          'lVersion': 1,
          'lAddress': '강남구',
          'lPaymentMethod': 'KaKaoPay',
        },
        {
          'cid': 5,
          'loginTime': '2025-12-12 07:20',
          'lStatus': '2',
          'lVersion': 1,
          'lAddress': '강남구',
          'lPaymentMethod': 'KaKaoPay',
        },
        {
          'cid': 6,
          'loginTime': '2023-12-12 07:20',
          'lStatus': '1',
          'lVersion': 1,
          'lAddress': '강남구',
          'lPaymentMethod': 'KaKaoPay',
        },
      ],
    );

    final productCombineList = MultiTableBatch(
      tables: [manufacturerBatch, productBaseBatch, imgBatch, productBatch],
    );

    final purchaseCombineList = MultiTableBatch(
      tables: [purchaseBatch, purchaseItemBatch],
    );

    final assembly = AssemblyDBHandler(
      dbName: '${config.kDBName}${config.kDBFileExt}',
      dVersion: config.kVersion,
    );

    final productResult = await assembly.insertMultiTableBatch(productCombineList);
    final purchaseResult = await assembly.insertMultiTableBatch(purchaseCombineList);

    final customerDAO = RDAO<Customer>(
      dbName: dbName,
      tableName: config.kTableCustomer,
      dVersion: dVersion,
      fromMap: Customer.fromMap,
    );

    final employeeDAO = RDAO<Employee>(
      dbName: dbName,
      tableName: config.tTableEmployee,
      dVersion: dVersion,
      fromMap: Employee.fromMap,
    );

    final purchaseItem = RDAO<PurchaseItem>(
      dbName: dbName,
      tableName: config.kTablePurchaseItem,
      dVersion: dVersion,
      fromMap: PurchaseItem.fromMap,
    );

    final loginHistory = RDAO<LoginHistory>(
      dbName: dbName,
      tableName: config.kTableLoginHistory,
      dVersion: dVersion,
      fromMap: LoginHistory.fromMap,
    );

    final customerResult = await customerDAO.insertBatch(customerBatch);
    final employeeResult = await employeeDAO.insertBatch(employeeBatch);
    final purchaseItemResult = await purchaseItem.insertBatch(purchaseItemBatch);
    final loginHistoryResult = await loginHistory.insertBatch(loginHistoryBatch);

    // for (int i = 0; i < productResult['Manufacturer']!.length; i++) {
    //   print('Manufacturer : $i , id: ${productResult['Manufacturer']![i]}');
    // }
    // for (int i = 0; i < productResult['ProductBase']!.length; i++) {
    //   print('ProductBase : $i , id: ${productResult['ProductBase']![i]}');
    // }
    // for (int i = 0; i < productResult['ProductImage']!.length; i++) {
    //   print('ProductImage : $i , id:${productResult['ProductImage']![i]}');
    // }
    // for (int i = 0; i < productResult['Product']!.length; i++) {
    //   print('Product : $i , id:${productResult['Product']![i]}');
    // }
    // for (int i = 0; i < customerResult.length; i++) {
    //   print('customerResult : $i , id:${customerResult![i]}');
    // }
    // for (int i = 0; i < employeeResult.length; i++) {
    //   print('employeeResult : $i , id:${employeeResult[i]}');
    // }
    // for (int i = 0; i < purchaseItemResult.length; i++) {
    //   print('purchaseItemResult : $i , id:${purchaseItemResult![i]}');
    // }
    // for (int i = 0; i < loginHistoryResult.length; i++) {
    //   print('LoginHistory : $i , id:${loginHistoryResult[i]}');
    // }
    //  for (int i = 0; i < purchaseResult['PurchaseItem']!.length; i++) {
    //   print('PurchaseItem : $i , id: ${purchaseResult['PurchaseItem']![i]}');
    // }
    // for (int i = 0; i < purchaseResult['Purchase']!.length; i++) {
    //   print('Purchase : $i , id: ${purchaseResult['Purchase']![i]}');
    // }
  }
}
