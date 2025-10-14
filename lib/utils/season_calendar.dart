import '../models/race_event.dart';
import '../models/race_strategy.dart';

class SeasonCalendar {
  static List<RaceEvent> getSeasonRaces() {
    return [
      // 1. أستراليا
      RaceEvent(
        id: 'australia',
        name: 'جائزة أستراليا الكبرى',
        country: 'أستراليا',
        city: 'ملبورن',
        circuitName: 'مضمار ألبرت بارك',
        totalLaps: 58,
        circuitLength: 5278,
        lapRecord: 76,
        baseWeather: WeatherType.changeable,
        difficulty: 1.1,
        characteristics: ['منعطفات متوسطة', 'طقس متغير', 'إطارات'],
      ),

      // 2. الصين
      RaceEvent(
        id: 'china',
        name: 'جائزة الصين الكبرى',
        country: 'الصين',
        city: 'شنغهاي',
        circuitName: 'مضمار شنغهاي الدولي',
        totalLaps: 56,
        circuitLength: 5451,
        lapRecord: 82,
        baseWeather: WeatherType.changeable,
        difficulty: 1.3,
        characteristics: ['مستقيمات طويلة', 'منعطفات بطيئة', 'تغير الطقس'],
      ),

      // 3. اليابان
      RaceEvent(
        id: 'japan',
        name: 'جائزة اليابان الكبرى',
        country: 'اليابان',
        city: 'سوزوكا',
        circuitName: 'مضمار سوزوكا',
        totalLaps: 53,
        circuitLength: 5807,
        lapRecord: 88,
        baseWeather: WeatherType.changeable,
        difficulty: 1.4,
        characteristics: ['شكل "8" مميز', 'تحدي الموثوقية', 'مناطق الفرملة'],
      ),

      // 4. البحرين
      RaceEvent(
        id: 'bahrain',
        name: 'جائزة البحرين الكبرى',
        country: 'البحرين',
        city: 'الصخير',
        circuitName: 'مضمار البحرين الدولي',
        totalLaps: 57,
        circuitLength: 5412,
        lapRecord: 91,
        baseWeather: WeatherType.dry,
        difficulty: 1.2,
        characteristics: ['ليلي/نهاري', 'مضمار صحراوي', 'كبح قوي'],
      ),

      // 5. السعودية
      RaceEvent(
        id: 'saudi_arabia',
        name: 'جائزة السعودية الكبرى',
        country: 'السعودية',
        city: 'جدة',
        circuitName: 'مضمار جدة كورنيش',
        totalLaps: 50,
        circuitLength: 6174,
        lapRecord: 104,
        baseWeather: WeatherType.dry,
        difficulty: 1.5,
        characteristics: ['ليلي', 'شوارع', 'سرعة عالية', 'حائط'],
      ),

      // 6. ميامي (الولايات المتحدة)
      RaceEvent(
        id: 'usa_miami',
        name: 'جائزة ميامي الكبرى',
        country: 'الولايات المتحدة',
        city: 'ميامي',
        circuitName: 'مضمار ميامي الدولي',
        totalLaps: 57,
        circuitLength: 5410,
        lapRecord: 85,
        baseWeather: WeatherType.changeable,
        difficulty: 1.3,
        characteristics: ['شوارع + حلبة مختلطة', 'حرارة ورطوبة', 'تآكل الإطارات'],
      ),

      // 7. إميليا-رومانيا (إيطاليا)
      RaceEvent(
        id: 'emilia_romagna',
        name: 'جائزة إميليا رومانيا الكبرى',
        country: 'إيطاليا',
        city: 'إميليا رومانيا',
        circuitName: 'مضمار إميليا‑رومانيا (إيمولا)',
        totalLaps: 63,
        circuitLength: 4909,
        lapRecord: 79,
        baseWeather: WeatherType.changeable,
        difficulty: 1.2,
        characteristics: ['منعطفات متوسطة', 'تاريخي', 'تحدي السرعة والتماسك'],
      ),

      // 8. موناكو
      RaceEvent(
        id: 'monaco',
        name: 'جائزة موناكو الكبرى',
        country: 'موناكو',
        city: 'مونت كارلو',
        circuitName: 'مضمار مونت كارلو',
        totalLaps: 78,
        circuitLength: 3337,
        lapRecord: 70,
        baseWeather: WeatherType.changeable,
        difficulty: 2.0,
        characteristics: ['شوارع ضيقة', 'صعوبة التجاوز', 'إطارات حرجة'],
      ),

      // 9. إسبانيا
      RaceEvent(
        id: 'spain',
        name: 'جائزة إسبانيا الكبرى',
        country: 'إسبانيا',
        city: 'برشلونة',
        circuitName: 'مضمار برشلونة-كاتالونيا',
        totalLaps: 66,
        circuitLength: 4670,
        lapRecord: 75,
        baseWeather: WeatherType.changeable,
        difficulty: 1.3,
        characteristics: ['توازن السيارة مهم', 'متوسط السرعات', 'إطارات'],
      ),

      // 10. كندا
      RaceEvent(
        id: 'canada',
        name: 'جائزة كندا الكبرى',
        country: 'كندا',
        city: 'مونتريال',
        circuitName: 'مضمار جيل فيلنوف',
        totalLaps: 70,
        circuitLength: 4361,
        lapRecord: 73,
        baseWeather: WeatherType.changeable,
        difficulty: 1.3,
        characteristics: ['منعطفات قوية', 'خلفيات الجدار', 'كبح متكرر'],
      ),

      // 11. النمسا
      RaceEvent(
        id: 'austria',
        name: 'جائزة النمسا الكبرى',
        country: 'النمسا',
        city: 'سبيلبرغ',
        circuitName: 'مضمار ريد بول رينغ',
        totalLaps: 71,
        circuitLength: 4318,
        lapRecord: 70,
        baseWeather: WeatherType.dry,
        difficulty: 1.4,
        characteristics: ['صعود وهبوط', 'أداء المحرك مهم', 'منعطفات متوسطة'],
      ),

      // 12. بريطانيا
      RaceEvent(
        id: 'britain',
        name: 'جائزة بريطانيا الكبرى',
        country: 'بريطانيا',
        city: 'سلفرستون',
        circuitName: 'مضمار سلفرستون',
        totalLaps: 52,
        circuitLength: 5891,
        lapRecord: 85,
        baseWeather: WeatherType.changeable,
        difficulty: 1.4,
        characteristics: ['تاريخي', 'سرعة عالية', 'طقس متغير'],
      ),

      // 13. بلجيكا
      RaceEvent(
        id: 'belgium',
        name: 'جائزة بلجيكا الكبرى',
        country: 'بلجيكا',
        city: 'ستافيلوت',
        circuitName: 'مضمار سبا فرانكورشومب',
        totalLaps: 44,
        circuitLength: 7004,
        lapRecord: 103,
        baseWeather: WeatherType.wet,
        difficulty: 1.7,
        characteristics: ['جبلية', 'طقس ممطر', 'يوف روج', 'متغير'],
      ),

      // 14. المجر
      RaceEvent(
        id: 'hungary',
        name: 'جائزة المجر الكبرى',
        country: 'المجر',
        city: 'بودابست',
        circuitName: 'مضمار الهنغارينغ',
        totalLaps: 70,
        circuitLength: 4381,
        lapRecord: 84,
        baseWeather: WeatherType.changeable,
        difficulty: 1.2,
        characteristics: ['منعطفات متوسطة', 'طقس حار', 'إطارات'],
      ),

      // 15. هولندا
      RaceEvent(
        id: 'netherlands',
        name: 'جائزة هولندا الكبرى',
        country: 'هولندا',
        city: 'هارلكم',
        circuitName: 'مضمار زاندفورت',
        totalLaps: 72,
        circuitLength: 4251,
        lapRecord: 65,
        baseWeather: WeatherType.changeable,
        difficulty: 1.5,
        characteristics: ['منعطفات سريعة', 'مرتفع ومنخفض', 'طقس بحرّي'],
      ),

      // 16. إيطاليا / مونزا
      RaceEvent(
        id: 'italy_monza',
        name: 'جائزة إيطاليا الكبرى',
        country: 'إيطاليا',
        city: 'مونزا',
        circuitName: 'مضمار مونزا',
        totalLaps: 53,
        circuitLength: 5793,
        lapRecord: 76,
        baseWeather: WeatherType.dry,
        difficulty: 1.8,
        characteristics: ['سرعة قصوى', 'مستقيمات طويلة', 'تحدي المحرك'],
      ),

      // 17. أذربيجان
      RaceEvent(
        id: 'azerbaijan',
        name: 'جائزة أذربيجان الكبرى',
        country: 'أذربيجان',
        city: 'باكو',
        circuitName: 'مضمار باكو شوارع',
        totalLaps: 51,
        circuitLength: 6002,
        lapRecord: 100,
        baseWeather: WeatherType.changeable,
        difficulty: 1.6,
        characteristics: ['شوارع ضيقة + مستقيات', 'جدار قريب', 'تحدي تركيز'],
      ),

      // 18. سنغافورة
      RaceEvent(
        id: 'singapore',
        name: 'جائزة سنغافورة الكبرى',
        country: 'سنغافورة',
        city: 'سنغافورة',
        circuitName: 'مضمار مارينا باي',
        totalLaps: 61,
        circuitLength: 5063,
        lapRecord: 95,
        baseWeather: WeatherType.changeable,
        difficulty: 1.6,
        characteristics: ['ليلي', 'رطوبة عالية', 'شوارع ضيقة', 'تكتيكي'],
      ),

      // 19. الولايات المتحدة / أوستن
      RaceEvent(
        id: 'usa_austin',
        name: 'جائزة الولايات المتحدة الكبرى',
        country: 'الولايات المتحدة',
        city: 'أوستن',
        circuitName: 'مضمار كوتا (COTA)',
        totalLaps: 56,
        circuitLength: 5360,
        lapRecord: 80,
        baseWeather: WeatherType.changeable,
        difficulty: 1.4,
        characteristics: ['مستقيمات + تقلبات', 'تضاريس', 'كبح متوسط'],
      ),

      // 20. المكسيك
      RaceEvent(
        id: 'mexico',
        name: 'جائزة المكسيك الكبرى',
        country: 'المكسيك',
        city: 'مكسيكو سيتي',
        circuitName: 'مضمار المكسيك الرديف',
        totalLaps: 71,
        circuitLength: 4305,
        lapRecord: 68,
        baseWeather: WeatherType.changeable,
        difficulty: 1.3,
        characteristics: ['ارتفاع كبير', 'حرارة منخفضة', 'هواء رقيق'],
      ),

      // 21. البرازيل
      RaceEvent(
        id: 'brazil',
        name: 'جائزة البرازيل الكبرى',
        country: 'البرازيل',
        city: 'ساو باولو',
        circuitName: 'مضمار إنتيرلاجوس',
        totalLaps: 71,
        circuitLength: 4309,
        lapRecord: 70,
        baseWeather: WeatherType.changeable,
        difficulty: 1.5,
        characteristics: ['منعطفات متوسطة', 'تضاريس', 'طقس غير مستقر'],
      ),

      // 22. لاس فيغاس
      RaceEvent(
        id: 'las_vegas',
        name: 'جائزة لاس فيغاس الكبرى',
        country: 'الولايات المتحدة',
        city: 'لاس فيغاس',
        circuitName: 'مضمار لاس فيغاس الشوارع',
        totalLaps: 50,
        circuitLength: 6100,
        lapRecord: 100,
        baseWeather: WeatherType.dry,
        difficulty: 1.6,
        characteristics: ['ليلي', 'شوارع طويلة', 'سرعة متوسطة'],
      ),

      // 23. قطر
      RaceEvent(
        id: 'qatar',
        name: 'جائزة قطر الكبرى',
        country: 'قطر',
        city: 'الدوحة',
        circuitName: 'مضمار لوسيل',
        totalLaps: 57,
        circuitLength: 5400,
        lapRecord: 90,
        baseWeather: WeatherType.dry,
        difficulty: 1.4,
        characteristics: ['ليلي', 'مضمار حديث', 'سرعة متوسطة'],
      ),

      // 24. أبوظبي
      RaceEvent(
        id: 'abu_dhabi',
        name: 'جائزة أبوظبي الكبرى',
        country: 'الإمارات',
        city: 'أبوظبي',
        circuitName: 'مضمار ياس مارينا',
        totalLaps: 55,
        circuitLength: 5281,
        lapRecord: 97,
        baseWeather: WeatherType.dry,
        difficulty: 1.2,
        characteristics: ['ليلي/نهاري', 'تحت الأضواء', 'ختامي'],
      ),
    ];
  }

  // دالة للحصول على سباق محدد حسب الجولة
  static RaceEvent getRaceByRound(int round, int seasonYear) {
    final calendar = getSeasonRaces(); // ✅ تغيير إلى getSeasonRaces
    final raceIndex = (round - 1) % calendar.length;
    return calendar[raceIndex];
  }

  // دالة للحصول على عدد السباقات في الموسم
  static int getTotalRaces(int seasonYear) {
    return getSeasonRaces().length; // ✅ تغيير إلى getSeasonRaces
  }

  // دالة للحصول على معلومات الموسم
  static Map<String, dynamic> getSeasonInfo(int seasonYear) {
    final calendar = getSeasonRaces(); // ✅ تغيير إلى getSeasonRaces
    return {
      'totalRaces': calendar.length,
      'seasonYear': seasonYear,
      'tracks': calendar.map((race) => race.circuitName).toList(),
      'countries': calendar.map((race) => race.country).toSet().toList(),
    };
  }
}