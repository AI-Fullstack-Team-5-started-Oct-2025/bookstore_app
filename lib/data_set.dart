import 'package:bookstore_app/model/customer.dart';
import 'package:bookstore_app/model/employee.dart';
import 'package:bookstore_app/model/product/manufacturer.dart';
import 'package:bookstore_app/model/product/product.dart';
import 'package:bookstore_app/model/product/product_base.dart';
import 'package:bookstore_app/model/product/product_image.dart';
import 'package:bookstore_app/model/sale/purchase.dart';
import 'package:bookstore_app/config.dart' as config;

class DataSet {
  
List<Manufacturer> manufacturerList = [ Manufacturer(mName: '뉴발란스'), Manufacturer(mName: '나이키')];

List<ProductBase> productBaseList = [
  ProductBase(
    pName: 'U740WN2',
    pDescription:
        '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.',
    pColor: "Black",
    pGender: 'Unisex',
    pStatus: '',
    pCategory: 'Running',
    pModelNumber: 'NEW009T1',
  ),
  ProductBase(
    pName: 'U740WN2',
    pDescription:
        '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.',
    pColor: "Gray",
    pGender: 'Unisex',
    pStatus: '',
    pCategory: 'Running',
    pModelNumber: 'NEW009T1',
  ),
  ProductBase(
    pName: 'U740WN2',
    pDescription:
        '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.',
    pColor: "White",
    pGender: 'Unisex',
    pStatus: '',
    pCategory: 'Running',
    pModelNumber: 'NEW009T1',
  ),
  ProductBase(
    pName: '나이키 샥스 TL',
    pDescription:
        '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.',
    pColor: "Black",
    pGender: 'Female',
    pStatus: '',
    pCategory: 'Running',
    pModelNumber: 'NIK321E3',
  ),
  ProductBase(
    pName: '나이키 샥스 TL',
    pDescription:
        '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.',
    pColor: "Gray",
    pGender: 'Female',
    pStatus: '',
    pCategory: 'Running',
    pModelNumber: 'NIK321E3',
  ),
  ProductBase(
    pName: '나이키 샥스 TL',
    pDescription:
        '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.',
    pColor: "White",
    pGender: 'Female',
    pStatus: '',
    pCategory: 'Running',
    pModelNumber: 'NIK321E3',
  ),
  ProductBase(
    pName: '나이키 에어포스 1',
    pDescription:
        '편안하고 내구성이 뛰어나며 유행을 타지 않는 고급스러운 스니커즈로, 프리미엄 가죽과 적절하게 배치된 미니 스우시가 클래식 아이템에 세련된 감각을 더해줍니다. 물론 1980년대를 떠올리게 하는 구조와 나이키 에어 쿠셔닝 등 모두가 사랑하는 전설적인 AF1의 룩과 감성은 고스란히 재현했습니다.',
    pColor: "Black",
    pGender: 'Female',
    pStatus: '',
    pCategory: 'Sneakers',
    pModelNumber: 'NISK09UY',
  ),
  ProductBase(
    pName: '나이키 에어포스 1',
    pDescription:
        '편안하고 내구성이 뛰어나며 유행을 타지 않는 고급스러운 스니커즈로, 프리미엄 가죽과 적절하게 배치된 미니 스우시가 클래식 아이템에 세련된 감각을 더해줍니다. 물론 1980년대를 떠올리게 하는 구조와 나이키 에어 쿠셔닝 등 모두가 사랑하는 전설적인 AF1의 룩과 감성은 고스란히 재현했습니다.',
    pColor: "Gray",
    pGender: 'Female',
    pStatus: '',
    pCategory: 'Sneakers',
    pModelNumber: 'NISK09UY',
  ),
  ProductBase(
    pName: '나이키 에어포스 1',
    pDescription:
        '편안하고 내구성이 뛰어나며 유행을 타지 않는 고급스러운 스니커즈로, 프리미엄 가죽과 적절하게 배치된 미니 스우시가 클래식 아이템에 세련된 감각을 더해줍니다. 물론 1980년대를 떠올리게 하는 구조와 나이키 에어 쿠셔닝 등 모두가 사랑하는 전설적인 AF1의 룩과 감성은 고스란히 재현했습니다.',
    pColor: "White",
    pGender: 'Female',
    pStatus: '',
    pCategory: 'Sneakers',
    pModelNumber: 'NISK09UY',
  ),
  ProductBase(
    pName: '나이키 페가수스 플러스',
    pDescription:
        '페가수스 플러스로 차원이 다른 반응성과 쿠셔닝을 느껴보세요. 전체적으로 적용된 초경량 줌X 폼이 일상의 러닝에 높은 에너지 반환력을 제공하기 때문에 활력 있게 달릴 수 있습니다. 그리고 신축성 좋은 플라이니트 갑피가 발을 꼭 맞게 감싸 매끄러운 핏을 선사합니다.',
    pColor: "Black",
    pGender: 'Male',
    pStatus: '',
    pCategory: 'Running',
    pModelNumber: 'NIKTY19Z',
  ),
  ProductBase(
    pName: '나이키 페가수스 플러스',
    pDescription:
        '페가수스 플러스로 차원이 다른 반응성과 쿠셔닝을 느껴보세요. 전체적으로 적용된 초경량 줌X 폼이 일상의 러닝에 높은 에너지 반환력을 제공하기 때문에 활력 있게 달릴 수 있습니다. 그리고 신축성 좋은 플라이니트 갑피가 발을 꼭 맞게 감싸 매끄러운 핏을 선사합니다.',
    pColor: "Gray",
    pGender: 'Male',
    pStatus: '',
    pCategory: 'Running',
    pModelNumber: 'NIKTY19Z',
  ),
  ProductBase(
    pName: '나이키 페가수스 플러스',
    pDescription:
        '페가수스 플러스로 차원이 다른 반응성과 쿠셔닝을 느껴보세요. 전체적으로 적용된 초경량 줌X 폼이 일상의 러닝에 높은 에너지 반환력을 제공하기 때문에 활력 있게 달릴 수 있습니다. 그리고 신축성 좋은 플라이니트 갑피가 발을 꼭 맞게 감싸 매끄러운 핏을 선사합니다.',
    pColor: "White",
    pGender: 'Male',
    pStatus: '',
    pCategory: 'Running',
    pModelNumber: 'NIKTY19Z',
  ),
];

List<ProductImage> productImageList = [
  // pbid: 1 (U740WN2)
  ProductImage(
    pbid: 1,
    imagePath:
        '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Black_01.png',
  ),
  ProductImage(
    pbid: 1,
    imagePath:
        '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Black_02.png',
  ),
  ProductImage(
    pbid: 1,
    imagePath:
        '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Black_03.png',
  ),
  ProductImage(
    pbid: 2,
    imagePath:
        '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Gray_01.png',
  ),
  ProductImage(
    pbid: 2,
    imagePath:
        '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Gray_02.png',
  ),
  ProductImage(
    pbid: 2,
    imagePath:
        '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Gray_03.png',
  ),
  ProductImage(
    pbid: 3,
    imagePath:
        '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_White_01.png',
  ),
  ProductImage(
    pbid: 3,
    imagePath:
        '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_White_02.png',
  ),
  ProductImage(
    pbid: 3,
    imagePath:
        '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_White_03.png',
  ),

  ProductImage(
    pbid: 4,
    imagePath: '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Black_01.avif',
  ),
  ProductImage(
    pbid: 4,
    imagePath: '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Black_02.avif',
  ),
  ProductImage(
    pbid: 4,
    imagePath: '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Black_03.avif',
  ),
  ProductImage(
    pbid: 5,
    imagePath: '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Gray_01.avif',
  ),
  ProductImage(
    pbid: 5,
    imagePath: '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Gray_02.avif',
  ),
  ProductImage(
    pbid: 5,
    imagePath: '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_Gray_03.avif',
  ),
  ProductImage(
    pbid: 6,
    imagePath: '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_White_01.avif',
  ),
  ProductImage(
    pbid: 6,
    imagePath: '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_White_02.avif',
  ),
  ProductImage(
    pbid: 6,
    imagePath: '${config.kImageAssetPath}Nike_Shox_TL/Nike_Shox_TL_White_03.avif',
  ),

  ProductImage(
    pbid: 7,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_01.avif',
  ),
  ProductImage(
    pbid: 7,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_02.avif',
  ),
  ProductImage(
    pbid: 7,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_03.avif',
  ),
  ProductImage(
    pbid: 8,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_01.avif',
  ),
  ProductImage(
    pbid: 8,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_02.avif',
  ),
  ProductImage(
    pbid: 8,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_03.avif',
  ),
  ProductImage(
    pbid: 9,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_01.avif',
  ),
  ProductImage(
    pbid: 9,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_02.avif',
  ),
  ProductImage(
    pbid: 9,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_03.avif',
  ),

  ProductImage(
    pbid: 10,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_01.avif',
  ),
  ProductImage(
    pbid: 10,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_02.avif',
  ),
  ProductImage(
    pbid: 10,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Black_03.avif',
  ),
  ProductImage(
    pbid: 11,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_01.avif',
  ),
  ProductImage(
    pbid: 11,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_02.avif',
  ),
  ProductImage(
    pbid: 11,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_Gray_03.avif',
  ),
  ProductImage(
    pbid: 12,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_01.avif',
  ),
  ProductImage(
    pbid: 12,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_02.avif',
  ),
  ProductImage(
    pbid: 12,
    imagePath: '${config.kImageAssetPath}Nike_Air_1/Nike_Air_1_White_03.avif',
  ),
];

List<Product> productList = [
  Product(pbid: 1, mfid: 1, size: 220, basePrice: 100000),
  Product(pbid: 1, mfid: 1, size: 230, basePrice: 110000),
  Product(pbid: 1, mfid: 1, size: 240, basePrice: 120000),
  Product(pbid: 1, mfid: 1, size: 250, basePrice: 130000),
  Product(pbid: 1, mfid: 1, size: 260, basePrice: 140000),
  Product(pbid: 1, mfid: 1, size: 270, basePrice: 150000),
  Product(pbid: 1, mfid: 1, size: 280, basePrice: 160000),

  Product(pbid: 2, mfid: 1, size: 220, basePrice: 100500),
  Product(pbid: 2, mfid: 1, size: 230, basePrice: 101500),
  Product(pbid: 2, mfid: 1, size: 240, basePrice: 102500),
  Product(pbid: 2, mfid: 1, size: 250, basePrice: 103500),
  Product(pbid: 2, mfid: 1, size: 260, basePrice: 104500),
  Product(pbid: 2, mfid: 1, size: 270, basePrice: 105500),
  Product(pbid: 2, mfid: 1, size: 280, basePrice: 106500),

  Product(pbid: 3, mfid: 1, size: 220, basePrice: 102000),
  Product(pbid: 3, mfid: 1, size: 230, basePrice: 102100),
  Product(pbid: 3, mfid: 1, size: 240, basePrice: 102200),
  Product(pbid: 3, mfid: 1, size: 250, basePrice: 102300),
  Product(pbid: 3, mfid: 1, size: 260, basePrice: 102400),
  Product(pbid: 3, mfid: 1, size: 270, basePrice: 102500),
  Product(pbid: 3, mfid: 1, size: 280, basePrice: 102600),

  Product(pbid: 4, mfid: 2, size: 220, basePrice: 180000),
  Product(pbid: 4, mfid: 2, size: 230, basePrice: 181000),
  Product(pbid: 4, mfid: 2, size: 240, basePrice: 182000),
  Product(pbid: 4, mfid: 2, size: 250, basePrice: 183000),
  Product(pbid: 4, mfid: 2, size: 260, basePrice: 184000),
  Product(pbid: 4, mfid: 2, size: 270, basePrice: 185000),
  Product(pbid: 4, mfid: 2, size: 280, basePrice: 186000),

  Product(pbid: 5, mfid: 2, size: 220, basePrice: 118000),
  Product(pbid: 5, mfid: 2, size: 230, basePrice: 123000),
  Product(pbid: 5, mfid: 2, size: 240, basePrice: 128000),
  Product(pbid: 5, mfid: 2, size: 250, basePrice: 133000),
  Product(pbid: 5, mfid: 2, size: 260, basePrice: 138000),
  Product(pbid: 5, mfid: 2, size: 270, basePrice: 143000),
  Product(pbid: 5, mfid: 2, size: 280, basePrice: 148000),

  Product(pbid: 6, mfid: 2, size: 220, basePrice: 98000),
  Product(pbid: 6, mfid: 2, size: 230, basePrice: 99500),
  Product(pbid: 6, mfid: 2, size: 240, basePrice: 101000),
  Product(pbid: 6, mfid: 2, size: 250, basePrice: 102500),
  Product(pbid: 6, mfid: 2, size: 260, basePrice: 104000),
  Product(pbid: 6, mfid: 2, size: 270, basePrice: 105500),
  Product(pbid: 6, mfid: 2, size: 280, basePrice: 107000),

  Product(pbid: 7, mfid: 2, size: 220, basePrice: 102000),
  Product(pbid: 7, mfid: 2, size: 230, basePrice: 103000),
  Product(pbid: 7, mfid: 2, size: 240, basePrice: 104000),
  Product(pbid: 7, mfid: 2, size: 250, basePrice: 105000),
  Product(pbid: 7, mfid: 2, size: 260, basePrice: 106000),
  Product(pbid: 7, mfid: 2, size: 270, basePrice: 107000),
  Product(pbid: 7, mfid: 2, size: 280, basePrice: 108000),

  Product(pbid: 8, mfid: 2, size: 220, basePrice: 175000),
  Product(pbid: 8, mfid: 2, size: 230, basePrice: 178000),
  Product(pbid: 8, mfid: 2, size: 240, basePrice: 181000),
  Product(pbid: 8, mfid: 2, size: 250, basePrice: 184000),
  Product(pbid: 8, mfid: 2, size: 260, basePrice: 187000),
  Product(pbid: 8, mfid: 2, size: 270, basePrice: 190000),
  Product(pbid: 8, mfid: 2, size: 280, basePrice: 193000),

  Product(pbid: 9, mfid: 2, size: 220, basePrice: 135000),
  Product(pbid: 9, mfid: 2, size: 230, basePrice: 140000),
  Product(pbid: 9, mfid: 2, size: 240, basePrice: 145000),
  Product(pbid: 9, mfid: 2, size: 250, basePrice: 150000),
  Product(pbid: 9, mfid: 2, size: 260, basePrice: 155000),
  Product(pbid: 9, mfid: 2, size: 270, basePrice: 160000),
  Product(pbid: 9, mfid: 2, size: 280, basePrice: 165000),

  Product(pbid: 10, mfid: 2, size: 220, basePrice: 112000),
  Product(pbid: 10, mfid: 2, size: 230, basePrice: 115000),
  Product(pbid: 10, mfid: 2, size: 240, basePrice: 118000),
  Product(pbid: 10, mfid: 2, size: 250, basePrice: 121000),
  Product(pbid: 10, mfid: 2, size: 260, basePrice: 124000),
  Product(pbid: 10, mfid: 2, size: 270, basePrice: 127000),
  Product(pbid: 10, mfid: 2, size: 280, basePrice: 130000),

  Product(pbid: 11, mfid: 2, size: 220, basePrice: 92000),
  Product(pbid: 11, mfid: 2, size: 230, basePrice: 94000),
  Product(pbid: 11, mfid: 2, size: 240, basePrice: 96000),
  Product(pbid: 11, mfid: 2, size: 250, basePrice: 98000),
  Product(pbid: 11, mfid: 2, size: 260, basePrice: 100000),
  Product(pbid: 11, mfid: 2, size: 270, basePrice: 102000),
  Product(pbid: 11, mfid: 2, size: 280, basePrice: 104000),

  Product(pbid: 12, mfid: 2, size: 220, basePrice: 198000),
  Product(pbid: 12, mfid: 2, size: 230, basePrice: 202000),
  Product(pbid: 12, mfid: 2, size: 240, basePrice: 206000),
  Product(pbid: 12, mfid: 2, size: 250, basePrice: 210000),
  Product(pbid: 12, mfid: 2, size: 260, basePrice: 214000),
  Product(pbid: 12, mfid: 2, size: 270, basePrice: 218000),
  Product(pbid: 12, mfid: 2, size: 280, basePrice: 222000),
];

List<Employee> employeeList = [
  Employee(
  eEmail: 'ma@wei.com',
  ePhoneNumber: '222-6789-5432',
  eName: '사마의',
  ePassword: 'qwer1234',
),
Employee(
  eEmail: 'oiling@wu.com',
  ePhoneNumber: '999-3211-0987',
  eName: '주유',
  ePassword: 'qwer1234',
),
Employee(
  eEmail: 'gongmyeong@shu.com',
  ePhoneNumber: '000-0987-6543',
  eName: '제갈공명',
  ePassword: 'qwer1234',
)
];

List<Customer> customerList = [
  Customer(
    cEmail: 'jojo@wei.com',
    cPhoneNumber: '222-9898-1212',
    cName: '조조',
    cPassword: 'qwer1234',
  ),
  Customer(
    cEmail: 'handbook@wu.com',
    cPhoneNumber: '999-7676-1987',
    cName: '손책',
    cPassword: 'qwer1234',
  ),
  Customer(
    cEmail: 'bigear@shu.com',
    cPhoneNumber: '000-1234-5678',
    cName: '유비',
    cPassword: 'qwer1234',
  ),
  Customer(
    cEmail: 'jangryo@wei.com',
    cPhoneNumber: '222-3452-7665',
    cName: '장료',
    cPassword: 'qwer1234',
  ),
  Customer(
    cEmail: 'sixhand@wu.com',
    cPhoneNumber: '999-1010-2929',
    cName: '육손',
    cPassword: 'qwer1234',
  ),
  Customer(
    cEmail: 'purpledraong@shu.com',
    cPhoneNumber: '000-0987-6543',
    cName: '조자룡',
    cPassword: 'qwer1234',
  ),
];
}