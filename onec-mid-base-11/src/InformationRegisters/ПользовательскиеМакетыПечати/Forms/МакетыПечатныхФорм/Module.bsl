///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем КонтекстВыбора;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьУсловноеОформление();
	
	ЗаполнитьТаблицуМакетовПечатныхФорм();
	Если Параметры.Свойство("ПоказыватьТолькоПользовательскиеИзмененные") Тогда
		ОтборПоИспользованиюМакета = "ИспользуемыеИзмененные";
	Иначе
		ОтборПоИспользованиюМакета = Элементы.ОтборПоИспользованиюМакета.СписокВыбора[0].Значение;
	КонецЕсли;
	
	ЕстьПравоИзменения = ПравоДоступа("Изменение", Метаданные.РегистрыСведений.ПользовательскиеМакетыПечати);
	ТолькоПросмотр = Не ЕстьПравоИзменения;
	Элементы.МакетыПечатныхФормГруппаПереключениеИспользуемогоМакета.Видимость = ЕстьПравоИзменения;
	Элементы.МакетыПечатныхФормУдалитьИзмененныйМакет.Видимость = ЕстьПравоИзменения;
	
	ЕстьДополнительныеЯзыки = Ложь;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность") Тогда
		МодульМультиязычностьСервер = ОбщегоНазначения.ОбщийМодуль("МультиязычностьСервер");
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность.Печать") Тогда
			МодульУправлениеПечатьюМультиязычность = ОбщегоНазначения.ОбщийМодуль("УправлениеПечатьюМультиязычность");
			ДополнительныеЯзыкиПечатныхФорм = МодульУправлениеПечатьюМультиязычность.ДополнительныеЯзыкиПечатныхФорм();
			
			Элементы.ОтборПоЯзыку.СписокВыбора.Добавить("", НСтр("ru = 'Все'"));
			Для Каждого Язык Из ДополнительныеЯзыкиПечатныхФорм Цикл
				ПредставлениеЯзыка = МодульМультиязычностьСервер.ПредставлениеЯзыка(Язык);
				Элементы.ОтборПоЯзыку.СписокВыбора.Добавить(ПредставлениеЯзыка);
			КонецЦикла;
			
			ЕстьДополнительныеЯзыки = ДополнительныеЯзыкиПечатныхФорм.Количество() > 0;
		КонецЕсли;
	КонецЕсли;
	
	Элементы.ГруппаДополнительнаяИнформация.Видимость = ЕстьДополнительныеЯзыки;
	Элементы.ОтборПоЯзыку.Видимость = ЕстьДополнительныеЯзыки;
	Элементы.МакетыДоступныеЯзыки.Видимость = ЕстьДополнительныеЯзыки;
	Элементы.МакетыДоступенПеревод.Видимость = ЕстьДополнительныеЯзыки;
	
	РежимОткрытияМакетаПросмотр = Не ЕстьПравоИзменения;

	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		СпрашиватьРежимОткрытияМакета = Ложь;
		РежимОткрытияМакетаПросмотр = Истина;
		Элементы.ГруппаОтборы.Группировка = ГруппировкаПодчиненныхЭлементовФормы.ГоризонтальнаяЕслиВозможно;
	КонецЕсли;
	
	АвтоНавигационнаяСсылка = Ложь;
	НавигационнаяСсылка = "e1cib/list/РегистрСведений.ПользовательскиеМакетыПечати";
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если (ИмяСобытия = "Запись_ТабличныйДокумент" Или ИмяСобытия = "Запись_ПользовательскиеМакетыПечати") И Источник.ВладелецФормы = ЭтотОбъект Тогда
		Если Не ТолькоПросмотр Тогда
			Элементы.Макеты.ТекущаяСтрока = ОбновитьОтображениеМакета(Параметр);
		КонецЕсли;
		ОбновитьОтображениеМакетов();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ОбновитьОтображениеМакета(Знач Параметр)
	
	ИдентификаторМакета = Параметр.ИмяОбъектаМетаданныхМакета;
	Макет = НайтиМакет(ИдентификаторМакета);
	Если Макет = Неопределено Тогда
		Для Каждого ГруппаМакетов Из Макеты.ПолучитьЭлементы() Цикл
			Если ГруппаМакетов.Владелец = Параметр.Владелец Тогда
				ДополнитьСписокМакетов(ГруппаМакетов.ПолучитьЭлементы(), ИдентификаторМакета);
				Макет = НайтиМакет(ИдентификаторМакета);
				ДополнитьОписаниеМакета(Макет);
				Прервать;
			КонецЕсли;
		КонецЦикла;
	Иначе
		ИзмененныеМакеты = ИзмененныеМакеты();
		
		Макет.Изменен = ИзмененныеМакеты[ИдентификаторМакета] <> Неопределено Или Не Макет.Поставляемый;
		Макет.ИспользуетсяИзмененный = Макет.Изменен И (ИзмененныеМакеты[ИдентификаторМакета] = Истина Или Не Макет.Поставляемый);
		Макет.ДоступныеЯзыки = ДоступныеЯзыкиМакета(Параметр.ИмяОбъектаМетаданныхМакета);
		Макет.КартинкаИспользования = -1;
		Если Макет.Изменен Тогда
			Макет.КартинкаИспользования = Число(Макет.Изменен) + Число(Макет.ИспользуетсяИзмененный);
		КонецЕсли;
		Если Параметр.Свойство("Представление") Тогда
			Макет.Представление = Параметр.Представление;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Макет.ПолучитьИдентификатор();
	
КонецФункции

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	
	Параметр = Новый Структура("Отказ", Ложь);
	Оповестить("ЗакрытиеФормыВладельца", Параметр, ЭтотОбъект);
	
	Если Параметр.Отказ Тогда
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	УстановитьОтборМакетов();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ДополнительнаяИнформацияОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность.Печать") Тогда
		МодульУправлениеПечатьюМультиязычностьКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("УправлениеПечатьюМультиязычностьКлиент");
		МодульУправлениеПечатьюМультиязычностьКлиент.ДополнительнаяИнформацияОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка);
	КонецЕсли;
	
КонецПроцедуры
	
#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыМакеты

&НаКлиенте
Процедура МакетыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ТекущиеДанные = Элементы.Макеты.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ТекущиеДанные.ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
		
	Если Поле.Имя = "МакетыКнопкаНастройкиДоступности" Тогда
		УсловияДоступности(Неопределено);
	Иначе
		ОткрытьМакетПечатнойФормы();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура МакетыПриАктивизацииСтроки(Элемент)
	
	УстановитьДоступностьКнопокКоманднойПанели();
	
КонецПроцедуры

&НаКлиенте
Процедура МакетыПриИзменении(Элемент)
	
	ТекущиеДанные = Элемент.ТекущиеДанные;
	Если ТекущиеДанные <> Неопределено И ЗначениеЗаполнено(ТекущиеДанные.Ссылка) Тогда
		УстановитьИспользованиеМакета(ТекущиеДанные.Ссылка, ТекущиеДанные.Используется);
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура УстановитьИспользованиеМакета(Макет, Используется)
	
	Справочники.МакетыПечатныхФорм.УстановитьИспользованиеМакета(Макет, Используется);
	ОбновитьПовторноИспользуемыеЗначения();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ИзменитьМакет(Команда)
	ОткрытьМакетПечатнойФормыДляРедактирования();
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьМакет(Команда)
	ОткрытьМакетПечатнойФормыДляПросмотра();
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьИзмененныйМакет(Команда)
	ПереключитьИспользованиеВыбранныхМакетов(Истина);
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьСтандартныйМакет(Команда)
	ПереключитьИспользованиеВыбранныхМакетов(Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ЗадатьДействиеПриВыбореМакетаПечатнойФормы(Команда)
	
	КонтекстВыбора = "ЗадатьДействиеПриВыбореМакетаПечатнойФормы";
	ОткрытьФорму("РегистрСведений.ПользовательскиеМакетыПечати.Форма.ВыбораРежимаОткрытияМакета", , ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьМакет(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПриВыбореИмениМакета", ЭтотОбъект, Ложь);
	ПоказатьВводСтроки(ОписаниеОповещения, НСтр("ru = 'Новая печатная форма'"), НСтр("ru = 'Введите наименование макета'"), 100, Ложь)
	
КонецПроцедуры

&НаКлиенте
Процедура УсловияДоступности(Команда)
	
	ТекущиеДанные = Элементы.Макеты.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ТекущиеДанные.Ссылка) Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыОткрытия = Новый Структура("Ключ", ТекущиеДанные.Ссылка);
	
	ОткрытьФорму("Справочник.МакетыПечатныхФорм.Форма.УсловияВидимостиВПодменюПечать", ПараметрыОткрытия, ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Начальное заполнение

&НаСервере
Процедура ЗаполнитьТаблицуМакетовПечатныхФорм()
	
	СписокМакетов = Новый ТаблицаЗначений();
	СписокМакетов.Колонки.Добавить("ОбъектМетаданных");
	СписокМакетов.Колонки.Добавить("Идентификатор");
	СписокМакетов.Колонки.Добавить("Представление");
	СписокМакетов.Колонки.Добавить("Владелец");
	СписокМакетов.Колонки.Добавить("ТипМакета");
	СписокМакетов.Колонки.Добавить("Картинка");
	СписокМакетов.Колонки.Добавить("СтрокаПоиска");
	СписокМакетов.Колонки.Добавить("ДоступныеЯзыки");
	СписокМакетов.Колонки.Добавить("Изменен");
	СписокМакетов.Колонки.Добавить("ИспользуетсяИзмененный");
	СписокМакетов.Колонки.Добавить("КартинкаИспользования");
	СписокМакетов.Колонки.Добавить("ДоступенПеревод");
	СписокМакетов.Колонки.Добавить("Ссылка");
	СписокМакетов.Колонки.Добавить("Используется");
	СписокМакетов.Колонки.Добавить("ДоступнаНастройкаВидимости");
	СписокМакетов.Колонки.Добавить("Поставляемый");
	СписокМакетов.Колонки.Добавить("ЭтоПечатнаяФорма");
	СписокМакетов.Колонки.Добавить("ДоступноСоздание");
	
	ИзмененныеМакеты = ИзмененныеМакеты();
	ДоступныеДляПереводаМакеты = Новый Соответствие;
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность.Печать") Тогда
		МодульУправлениеПечатьюМультиязычность = ОбщегоНазначения.ОбщийМодуль("УправлениеПечатьюМультиязычность");
		ДоступныеДляПереводаМакеты = МодульУправлениеПечатьюМультиязычность.ДоступныеДляПереводаМакеты();
	КонецЕсли;
	
	Для Каждого ОписаниеМакета Из УправлениеПечатью.МакетыПечатныхФорм() Цикл
		
		Владелец = ОписаниеМакета.Значение;
		ИмяВладельца = ?(Метаданные.ОбщиеМакеты = Владелец, "ОбщийМакет", Владелец.ПолноеИмя());
		
		ОбъектМетаданных = ОписаниеМакета.Ключ;
		ИмяОбъектаМетаданныхМакета = ИмяВладельца + "." + ОбъектМетаданных.Имя;
		ПредставлениеМакета = ОбъектМетаданных.Представление();
		
		ТипМакета = ТипМакета(ОбъектМетаданных.Имя, ИмяВладельца);
		
		Макет = СписокМакетов.Добавить();
		Макет.ОбъектМетаданных = ОбъектМетаданных;
		Макет.Идентификатор = ИмяОбъектаМетаданныхМакета;
		Макет.Представление = ПредставлениеМакета;
		Макет.Владелец = ?(Владелец = Метаданные.ОбщиеМакеты, Неопределено, Владелец);
		Макет.ТипМакета = ТипМакета;
		Макет.Картинка = ИндексКартинки(ТипМакета);
		Макет.Изменен = ИзмененныеМакеты[ИмяОбъектаМетаданныхМакета] <> Неопределено;
		Макет.ИспользуетсяИзмененный = Макет.Изменен И ИзмененныеМакеты[ИмяОбъектаМетаданныхМакета];
		Макет.ДоступенПеревод = ДоступныеДляПереводаМакеты[ОбъектМетаданных] = Истина;
		Макет.Используется = Истина;
		Макет.Поставляемый = Истина;
	КонецЦикла;

	ВладельцыМакетов = ОбщегоНазначения.ИдентификаторыОбъектовМетаданных(СписокМакетов.ВыгрузитьКолонку("Владелец"), Ложь);
	
	Для Каждого Макет Из СписокМакетов Цикл
		Если Макет.Владелец <> Неопределено И ВладельцыМакетов[Макет.Владелец.ПолноеИмя()] <> Неопределено Тогда
			Макет.Владелец = ВладельцыМакетов[Макет.Владелец.ПолноеИмя()];
			Макет.ЭтоПечатнаяФорма = УправлениеПечатью.ЭтоПечатнаяФорма(Макет.Идентификатор, Макет.Владелец);
			Макет.ДоступенПеревод = Макет.ДоступенПеревод Или Макет.ЭтоПечатнаяФорма;
		КонецЕсли;
	КонецЦикла;
	
	ДополнитьСписокМакетов(СписокМакетов);
	
	ИсточникиКомандПечати = УправлениеПечатью.ИсточникиКомандПечати();
	ИсточникиДанныхПечати = ОбщегоНазначения.ИдентификаторыОбъектовМетаданных(ИсточникиКомандПечати, Ложь);
	ОбщегоНазначенияКлиентСервер.ДополнитьСоответствие(ИсточникиДанныхПечати, ВладельцыМакетов, Ложь);
	
	ВладельцыМакетов = Новый СписокЗначений();
	Для Каждого Источник Из ИсточникиДанныхПечати Цикл
		Если Не ЗначениеЗаполнено(Источник.Значение) Тогда
			Продолжить;
		КонецЕсли;
		ВладельцыМакетов.Добавить(Источник.Значение, Источник.Значение);
	КонецЦикла;
	
	ИдентификаторыОбъектовМетаданных = ВладельцыМакетов.ВыгрузитьЗначения();
	ЗначенияПустойСсылки = ОбщегоНазначения.ЗначениеРеквизитаОбъектов(ИдентификаторыОбъектовМетаданных, "ЗначениеПустойСсылки");
	
	ВладельцыМакетов.СортироватьПоПредставлению();
	ВладельцыМакетов.Добавить(Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка(), НСтр("ru = 'Прочие'"));
	
	ГруппыМакетов = Новый Соответствие();
	Для Каждого Владелец Из ВладельцыМакетов Цикл
		ГруппаМакетов = Макеты.ПолучитьЭлементы().Добавить();
		ГруппаМакетов.Представление = Владелец.Представление;
		ГруппаМакетов.КартинкаГруппы = БиблиотекаКартинок.Папка;
		ГруппаМакетов.Картинка = -1;
		ГруппаМакетов.КартинкаИспользования = -1;
		ГруппаМакетов.ЭтоГруппа = Истина;
		ГруппаМакетов.Используется = Истина;
		ГруппаМакетов.Владелец = Владелец.Значение;
		ГруппаМакетов.ДоступноСоздание = ЗначенияПустойСсылки[Владелец.Значение] <> Неопределено;
		
		ГруппыМакетов.Вставить(Владелец.Значение, ГруппаМакетов);
	КонецЦикла;
	
	СписокМакетов.Сортировать("Владелец, Представление");
	ГруппаМакетов = Неопределено;
	Для Каждого ОписаниеМакета Из СписокМакетов Цикл
		Если Не ЗначениеЗаполнено(ОписаниеМакета.Владелец)
			Или ГруппыМакетов[ОписаниеМакета.Владелец] = Неопределено Тогда
			ОписаниеМакета.Владелец = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка();
		КонецЕсли;
		
		ГруппаМакетов = ГруппыМакетов[ОписаниеМакета.Владелец];
		Макет = ГруппаМакетов.ПолучитьЭлементы().Добавить();
		ЗаполнитьЗначенияСвойств(Макет, ОписаниеМакета);
		ДополнитьОписаниеМакета(Макет);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ДополнитьОписаниеМакета(Макет)
	
	Макет.ИмяОбъектаМетаданныхМакета = Макет.Идентификатор;
	Макет.ДоступныеЯзыки = ДоступныеЯзыкиМакета(Макет.Идентификатор);
	Макет.КартинкаИспользования = -1;
	Если Макет.Изменен Тогда
		Макет.КартинкаИспользования = Число(Макет.Изменен) + Число(Макет.ИспользуетсяИзмененный);
	КонецЕсли;
	Макет.СтрокаПоиска = Макет.Представление + " " + Макет.ТипМакета;
	Макет.ДоступноСоздание = Макет.ПолучитьРодителя().ДоступноСоздание;
	
КонецПроцедуры

&НаСервере
Процедура ДополнитьСписокМакетов(СписокМакетов, Знач Идентификатор = Неопределено)
	
	Если ЗначениеЗаполнено(Идентификатор) Тогда
		Идентификатор = Новый УникальныйИдентификатор(Сред(Идентификатор, 4));
	Иначе
		Идентификатор = Новый УникальныйИдентификатор("00000000-0000-0000-0000-000000000000");
	КонецЕсли;
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	МакетыПечатныхФорм.Ссылка,
	|	МакетыПечатныхФорм.ИсточникДанных КАК Владелец,
	|	МакетыПечатныхФорм.Представление,
	|	МакетыПечатныхФорм.Используется,
	|	МакетыПечатныхФорм.ТипМакета,
	|	МакетыПечатныхФорм.Идентификатор
	|ИЗ
	|	Справочник.МакетыПечатныхФорм КАК МакетыПечатныхФорм
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ИдентификаторыОбъектовМетаданных КАК ИдентификаторыОбъектовМетаданных
	|		ПО МакетыПечатныхФорм.ИсточникДанных = ИдентификаторыОбъектовМетаданных.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ИдентификаторыОбъектовРасширений КАК ИдентификаторыОбъектовРасширений
	|		ПО МакетыПечатныхФорм.ИсточникДанных = ИдентификаторыОбъектовРасширений.Ссылка
	|ГДЕ
	|	(НЕ &ОтборУстановлен
	|	ИЛИ МакетыПечатныхФорм.Идентификатор = &Идентификатор)
	|	И НЕ МакетыПечатныхФорм.ПометкаУдаления";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ОтборУстановлен", ЗначениеЗаполнено(Идентификатор));
	Запрос.УстановитьПараметр("Идентификатор", Идентификатор);
	Выборка = Запрос.Выполнить().Выбрать();

	Пока Выборка.Следующий() Цикл
		Макет = СписокМакетов.Добавить();
		ЗаполнитьЗначенияСвойств(Макет, Выборка);

		Макет.Картинка = ИндексКартинки(Макет.ТипМакета);
		Макет.Изменен = Истина;
		Макет.ИспользуетсяИзмененный = Истина;
		Макет.ДоступенПеревод = Истина;
		Макет.Идентификатор = "ПФ_" + Строка(Макет.Идентификатор);
		Макет.ДоступнаНастройкаВидимости = Истина;
		Макет.ЭтоПечатнаяФорма = Истина;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ДоступныеЯзыкиМакета(Знач ИмяОбъектаМетаданныхМакета)
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность.Печать") Тогда
		МодульУправлениеПечатьюМультиязычность = ОбщегоНазначения.ОбщийМодуль("УправлениеПечатьюМультиязычность");
		Возврат МодульУправлениеПечатьюМультиязычность.ПредставлениеЯзыковМакета(ИмяОбъектаМетаданныхМакета);
	КонецЕсли;
	
	Возврат "";
	
КонецФункции

&НаСервере
Функция ТипМакета(ИмяОбъектаМетаданныхМакета, ИмяОбъекта = "ОбщийМакет")
	
	Позиция = СтрНайти(ИмяОбъектаМетаданныхМакета, "ПФ_");
	Если Позиция = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если ИмяОбъекта = "ОбщийМакет" Тогда
		МакетПечатнойФормы = ПолучитьОбщийМакет(ИмяОбъектаМетаданныхМакета);
	Иначе
		УстановитьОтключениеБезопасногоРежима(Истина);
		УстановитьПривилегированныйРежим(Истина);
		
		МакетПечатнойФормы = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(ИмяОбъекта).ПолучитьМакет(ИмяОбъектаМетаданныхМакета);
		
		УстановитьПривилегированныйРежим(Ложь);
		УстановитьОтключениеБезопасногоРежима(Ложь);
	КонецЕсли;
	
	ТипМакета = Неопределено;
	
	Если ТипЗнч(МакетПечатнойФормы) = Тип("ТабличныйДокумент") Тогда
		ТипМакета = "MXL";
	ИначеЕсли ТипЗнч(МакетПечатнойФормы) = Тип("ДвоичныеДанные") Тогда
		ТипМакета = ВРег(УправлениеПечатьюСлужебный.ОпределитьРасширениеФайлаДанныхПоСигнатуре(МакетПечатнойФормы));
	КонецЕсли;
	
	Возврат ТипМакета;
	
КонецФункции

&НаСервере
Функция ИндексКартинки(Знач ТипМакета)
	
	ТипыМакетов = Новый Соответствие;
	ТипыМакетов.Вставить("DOC", 0);
	ТипыМакетов.Вставить("DOCX", 0);
	ТипыМакетов.Вставить("ODT", 1);
	ТипыМакетов.Вставить("MXL", 2);
	
	Результат = ТипыМакетов[ВРег(ТипМакета)];
	Возврат ?(Результат = Неопределено, -1, Результат);
	
КонецФункции 

// Отборы

&НаКлиенте
Процедура УстановитьОтборМакетов(Текст = Неопределено);

	ПоказыватьИзмененные = Истина;
	ПоказыватьНеизмененные = Истина;
	ПоказыватьИспользуемые = Истина;
	ПоказыватьНеиспользуемые = Истина;
	
	Если ОтборПоИспользованиюМакета = "Измененные" Тогда
		ПоказыватьНеизмененные = Ложь;
	ИначеЕсли ОтборПоИспользованиюМакета = "НеИзмененные" Тогда
		ПоказыватьИзмененные = Ложь;
	ИначеЕсли ОтборПоИспользованиюМакета = "ИспользуемыеИзмененные" Тогда
		ПоказыватьНеиспользуемые = Ложь;
		ПоказыватьНеИзмененные = Ложь;
	ИначеЕсли ОтборПоИспользованиюМакета = "НеИспользуемыеИзмененные" Тогда
		ПоказыватьНеизмененные = Ложь;
		ПоказыватьИспользуемые = Ложь;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СтрокаПоискаИзменениеТекстаРедактирования(Элемент, Текст, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	СтрокаПоиска = Текст;
КонецПроцедуры

&НаКлиенте
Процедура СтрокаПоискаПриИзменении(Элемент)
	Если ЗначениеЗаполнено(СтрокаПоиска) И Элементы.СтрокаПоиска.СписокВыбора.НайтиПоЗначению(СтрокаПоиска) = Неопределено Тогда
		Элементы.СтрокаПоиска.СписокВыбора.Добавить(СтрокаПоиска);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОтборПоВидуИспользуемогоМакетаПриИзменении(Элемент)
	УстановитьОтборМакетов();
КонецПроцедуры

&НаКлиенте
Процедура ОтборПоИспользованиюМакетаОчистка(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОтборПоИспользованиюМакета = Элементы.ОтборПоИспользованиюМакета.СписокВыбора[0].Значение;
	УстановитьОтборМакетов();
КонецПроцедуры

// Открытие макета

&НаКлиенте
Процедура ОткрытьМакетПечатнойФормы()
	
	Если РежимОткрытияМакетаПросмотр Тогда
		ОткрытьМакетПечатнойФормыДляПросмотра();
	Иначе
		ОткрытьМакетПечатнойФормыДляРедактирования();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьМакетПечатнойФормыДляПросмотра()
	
	ТекущиеДанные = Элементы.Макеты.ТекущиеДанные;
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("ИмяОбъектаМетаданныхМакета", ТекущиеДанные.ИмяОбъектаМетаданныхМакета);
	ПараметрыОткрытия.Вставить("ТипМакета", ТекущиеДанные.ТипМакета);
	ПараметрыОткрытия.Вставить("ТолькоОткрытие", Истина);
	
	Если ТекущиеДанные.ТипМакета = "MXL" Тогда
		ПараметрыОткрытия.Вставить("ИмяДокумента", ТекущиеДанные.Представление);
		ОткрытьФорму("ОбщаяФорма.РедактированиеТабличногоДокумента", ПараметрыОткрытия, ЭтотОбъект);
		Возврат;
	КонецЕсли;
	
	ОткрытьФорму("РегистрСведений.ПользовательскиеМакетыПечати.Форма.РедактированиеМакета", ПараметрыОткрытия, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьМакетПечатнойФормыДляРедактирования()
	
	ТекущиеДанные = Элементы.Макеты.ТекущиеДанные;
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("ИмяОбъектаМетаданныхМакета", ТекущиеДанные.ИмяОбъектаМетаданныхМакета);
	ПараметрыОткрытия.Вставить("ТипМакета", ТекущиеДанные.ТипМакета);
	ПараметрыОткрытия.Вставить("Ссылка", ТекущиеДанные.Ссылка);
	ПараметрыОткрытия.Вставить("Владелец", ТекущиеДанные.Владелец);
	
	Если ТекущиеДанные.ТипМакета = "MXL" Тогда
		ПараметрыОткрытия.Вставить("ИмяДокумента", ТекущиеДанные.Представление);
		ПараметрыОткрытия.Вставить("Редактирование", Истина);
		ОткрытьФорму("ОбщаяФорма.РедактированиеТабличногоДокумента", ПараметрыОткрытия, ЭтотОбъект);
		Возврат;
	КонецЕсли;
	
	ОткрытьФорму("РегистрСведений.ПользовательскиеМакетыПечати.Форма.РедактированиеМакета", ПараметрыОткрытия, ЭтотОбъект);
	
КонецПроцедуры

// Действия с макетами

&НаКлиенте
Процедура ПереключитьИспользованиеВыбранныхМакетов(ИспользуетсяИзмененный)
	ПереключаемыеМакеты = Новый Массив;
	Для Каждого ВыделеннаяСтрока Из Элементы.Макеты.ВыделенныеСтроки Цикл
		ТекущиеДанные = Элементы.Макеты.ДанныеСтроки(ВыделеннаяСтрока);
		Если ТекущиеДанные.Изменен Тогда
			ТекущиеДанные.ИспользуетсяИзмененный = ИспользуетсяИзмененный;
			УстановитьКартинкуИспользования(ТекущиеДанные);
			ПереключаемыеМакеты.Добавить(ТекущиеДанные.ИмяОбъектаМетаданныхМакета);
		КонецЕсли;
	КонецЦикла;
	УстановитьИспользованиеИзмененныхМакетов(ПереключаемыеМакеты, ИспользуетсяИзмененный);
	УстановитьДоступностьКнопокКоманднойПанели();
КонецПроцедуры

&НаСервереБезКонтекста
Процедура УстановитьИспользованиеИзмененныхМакетов(Макеты, ИспользуетсяИзмененный)
	
	РегистрыСведений.ПользовательскиеМакетыПечати.УстановитьИспользованиеИзмененныхМакетов(Макеты, ИспользуетсяИзмененный);
	
КонецПроцедуры

&НаКлиенте
Процедура УдалитьВыбранныеИзмененныеМакеты(Команда)
	УдаляемыеМакеты = Новый Массив;
	Для Каждого ВыделеннаяСтрока Из Элементы.Макеты.ВыделенныеСтроки Цикл
		ТекущиеДанные = Элементы.Макеты.ДанныеСтроки(ВыделеннаяСтрока);
		ТекущиеДанные.ИспользуетсяИзмененный = Ложь;
		ТекущиеДанные.Изменен = Ложь;
		УстановитьКартинкуИспользования(ТекущиеДанные);
		УдаляемыеМакеты.Добавить(ТекущиеДанные.ИмяОбъектаМетаданныхМакета);
	КонецЦикла;
	УдалитьИзмененныеМакеты(УдаляемыеМакеты);
	УстановитьДоступностьКнопокКоманднойПанели();
КонецПроцедуры

&НаСервереБезКонтекста
Процедура УдалитьИзмененныеМакеты(УдаляемыеМакеты)
	
	Для Каждого ИмяОбъектаМетаданныхМакета Из УдаляемыеМакеты Цикл
		УправлениеПечатью.УдалитьМакет(ИмяОбъектаМетаданныхМакета);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьОтображениеМакетов();
	
	УстановитьДоступностьКнопокКоманднойПанели();
	
КонецПроцедуры

// Общие

&НаКлиенте
Процедура УстановитьКартинкуИспользования(ОписаниеМакета)
	ОписаниеМакета.КартинкаИспользования = -1;
	Если ОписаниеМакета.Изменен Тогда
		ОписаниеМакета.КартинкаИспользования = Число(ОписаниеМакета.Изменен) + Число(ОписаниеМакета.ИспользуетсяИзмененный);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДоступностьКнопокКоманднойПанели()
	
	ТекущийМакет = Элементы.Макеты.ТекущиеДанные;
	ТекущийМакетВыбран = ТекущийМакет <> Неопределено;
	ВыбраноНесколькоМакетов = Элементы.Макеты.ВыделенныеСтроки.Количество() > 1;
	
	ИспользоватьИзмененныйМакетДоступность = Ложь;
	ИспользоватьСтандартныйМакетДоступность = Ложь;
	УдалитьИзмененныйМакетДоступность = Ложь;
	УдалитьМакетВидимость = Ложь;
	
	Для Каждого ВыделеннаяСтрока Из Элементы.Макеты.ВыделенныеСтроки Цикл
		ТекущийМакет = Элементы.Макеты.ДанныеСтроки(ВыделеннаяСтрока);
		ИспользоватьИзмененныйМакетДоступность = ТекущийМакетВыбран И ТекущийМакет.Изменен И Не ТекущийМакет.ИспользуетсяИзмененный И Не ЗначениеЗаполнено(ТекущийМакет.Ссылка) Или ВыбраноНесколькоМакетов И ИспользоватьИзмененныйМакетДоступность;
		ИспользоватьСтандартныйМакетДоступность = ТекущийМакетВыбран И ТекущийМакет.Изменен И ТекущийМакет.ИспользуетсяИзмененный И Не ЗначениеЗаполнено(ТекущийМакет.Ссылка) Или ВыбраноНесколькоМакетов И ИспользоватьСтандартныйМакетДоступность;
		УдалитьИзмененныйМакетДоступность = ТекущийМакетВыбран И ТекущийМакет.Изменен  И Не ЗначениеЗаполнено(ТекущийМакет.Ссылка) Или ВыбраноНесколькоМакетов И УдалитьИзмененныйМакетДоступность;
		УдалитьМакетВидимость = ТекущийМакетВыбран И ЗначениеЗаполнено(ТекущийМакет.Ссылка) Или ВыбраноНесколькоМакетов И УдалитьМакетВидимость;
	КонецЦикла;
	
	Элементы.МакетыПечатныхФормИспользоватьИзмененныйМакет.Доступность = ИспользоватьИзмененныйМакетДоступность;
	Элементы.МакетыПечатныхФормИспользоватьСтандартныйМакет.Доступность = ИспользоватьСтандартныйМакетДоступность;
	Элементы.МакетыПечатныхФормУдалитьИзмененныйМакет.Доступность = УдалитьИзмененныйМакетДоступность;
	
	Элементы.МакетыКонтекстноеМенюУдалитьИзмененныйМакет.Видимость = УдалитьИзмененныйМакетДоступность;
	Элементы.МакетыКонтекстноеМенюУдалитьМакет.Видимость = УдалитьМакетВидимость;
	Элементы.МакетыУсловияДоступности.Доступность = ТекущийМакетВыбран И ТекущийМакет.ДоступнаНастройкаВидимости;
	Элементы.МакетыСкопировать.Доступность = ТекущийМакетВыбран И ТекущийМакет.ЭтоПечатнаяФорма И Не ВыбраноНесколькоМакетов;
	Элементы.МакетыДобавитьМакет.Доступность = ТекущийМакетВыбран И ТекущийМакет.ДоступноСоздание;
	Элементы.МакетыИзменитьМакет.Доступность = ТекущийМакетВыбран И Не ТекущийМакет.ЭтоГруппа;
	
КонецПроцедуры

&НаКлиенте
Процедура Скопировать(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПриВыбореИмениМакета", ЭтотОбъект, Истина);
	ПоказатьВводСтроки(ОписаниеОповещения, НСтр("ru = 'Новая печатная форма'"), НСтр("ru = 'Введите наименование макета'"), 100, Ложь)
	
КонецПроцедуры

&НаКлиенте
Процедура ПриВыбореИмениМакета(ИмяМакета, Копирование) Экспорт
	
	Если Не ЗначениеЗаполнено(ИмяМакета) Тогда
		Возврат;
	КонецЕсли;
	
	ТекущиеДанные = Элементы.Макеты.ТекущиеДанные;
	
	ТипМакета = "MXL";
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("ТипМакета", ТипМакета);
	ПараметрыОткрытия.Вставить("Владелец", ТекущиеДанные.Владелец);
	ПараметрыОткрытия.Вставить("ИмяДокумента", ИмяМакета);

	Если Копирование Тогда
		ПараметрыОткрытия.Вставить("ИмяОбъектаМетаданныхМакета", ТекущиеДанные.ИмяОбъектаМетаданныхМакета);
		ПараметрыОткрытия.Вставить("Копирование", Копирование);
	КонецЕсли;
	
	Если ТипМакета = "MXL" Тогда
		ПараметрыОткрытия.Вставить("Редактирование", Истина);
		ОткрытьФорму("ОбщаяФорма.РедактированиеТабличногоДокумента", ПараметрыОткрытия, ЭтотОбъект);
		Возврат;
	КонецЕсли;
	
	ОткрытьФорму("РегистрСведений.ПользовательскиеМакетыПечати.Форма.РедактированиеМакета", ПараметрыОткрытия, ЭтотОбъект);
	
КонецПроцедуры

&НаСервере
Функция ИзмененныеМакеты()
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ИзмененныеМакеты.ИмяМакета,
	|	ИзмененныеМакеты.Объект,
	|	ИзмененныеМакеты.Использование
	|ИЗ
	|	РегистрСведений.ПользовательскиеМакетыПечати КАК ИзмененныеМакеты";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	ИзмененныеМакеты = Запрос.Выполнить().Выгрузить();
	
	ЯзыкиПечатныхФорм = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(ОбщегоНазначения.КодОсновногоЯзыка());
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность.Печать") Тогда
		МодульУправлениеПечатьюМультиязычность = ОбщегоНазначения.ОбщийМодуль("УправлениеПечатьюМультиязычность");
		ЯзыкиПечатныхФорм = МодульУправлениеПечатьюМультиязычность.ДоступныеЯзыки();
	КонецЕсли;
	
	Результат = Новый Соответствие;
	
	Для Каждого Макет Из ИзмененныеМакеты Цикл
		ИмяМакета = Макет.ИмяМакета;
		
		ИменаМакета = Новый Массив;
		ИменаМакета.Добавить(ИмяМакета);
		
		Для Каждого КодЯзыка Из ЯзыкиПечатныхФорм Цикл
			Если СтрНайти(ИмяМакета, "_MXL_") И СтрЗаканчиваетсяНа(ИмяМакета, "_" + КодЯзыка) Тогда
				ИмяМакета = Лев(ИмяМакета, СтрДлина(ИмяМакета) - СтрДлина(КодЯзыка) - 1);
				ИменаМакета.Добавить(ИмяМакета);
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Для Каждого ИмяМакета Из ИменаМакета Цикл
			ИмяОбъектаМетаданныхМакета = Макет.Объект + "." + ИмяМакета;
			Результат.Вставить(ИмяОбъектаМетаданныхМакета, Макет.Использование);
		КонецЦикла;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция НайтиМакет(Идентификатор)
	
	ГруппыМакетов = Макеты.ПолучитьЭлементы();
	Для Каждого ГруппаМакетов Из ГруппыМакетов Цикл
		Для Каждого Макет Из ГруппаМакетов.ПолучитьЭлементы() Цикл
			Если Макет.Идентификатор = Идентификатор Тогда
				Возврат Макет;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

&НаКлиенте
Процедура УдалитьМакет(Команда)
	
	ТекущиеДанные = Элементы.Макеты.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИдентификаторМакета = ТекущиеДанные.Идентификатор;
	УдалитьМакетНаСервере(ИдентификаторМакета);
	Элементы.Макеты.ТекущиеДанные.ПолучитьРодителя().ПолучитьЭлементы().Удалить(Элементы.Макеты.ТекущиеДанные);
	
КонецПроцедуры

&НаСервере
Процедура УдалитьМакетНаСервере(ИдентификаторМакета)
	
	УправлениеПечатью.УдалитьМакет(ИдентификаторМакета);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	УсловноеОформление.Элементы.Очистить();
	
	// Цвет отключенных
	
	ЭлементОформления = УсловноеОформление.Элементы.Добавить();
	
	ОформляемоеПоле = ЭлементОформления.Поля.Элементы.Добавить();
	ОформляемоеПоле.Поле = Новый ПолеКомпоновкиДанных("Макеты");
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.Используется");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Ложь;
	
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("ЦветТекста", ЦветаСтиля.ТекстЗапрещеннойЯчейкиЦвет);
	
	// Скрытие флажка использования для групп
	
	ЭлементОформления = УсловноеОформление.Элементы.Добавить();
	
	ОформляемоеПоле = ЭлементОформления.Поля.Элементы.Добавить();
	ОформляемоеПоле.Поле = Новый ПолеКомпоновкиДанных("МакетыИспользуется");
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.ЭтоГруппа");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Истина;
	
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Отображать", Ложь);
	
	// Скрытие флажка использования для поставляемых макетов
	
	ЭлементОформления = УсловноеОформление.Элементы.Добавить();
	
	ОформляемоеПоле = ЭлементОформления.Поля.Элементы.Добавить();
	ОформляемоеПоле.Поле = Новый ПолеКомпоновкиДанных("МакетыИспользуется");
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.Поставляемый");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Истина;
	
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Отображать", Ложь);	
	
	// Поиск по строке
	
	ЭлементОформления = УсловноеОформление.Элементы.Добавить();
	
	ОформляемоеПоле = ЭлементОформления.Поля.Элементы.Добавить();
	ОформляемоеПоле.Поле = Новый ПолеКомпоновкиДанных("Макеты");
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.СтрокаПоиска");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.НеСодержит;
	ЭлементОтбора.ПравоеЗначение = Новый ПолеКомпоновкиДанных("СтрокаПоиска");

	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.ЭтоГруппа");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Ложь;
	
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Отображать", Ложь);
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);
	
	// Поиск по языку
	
	ЭлементОформления = УсловноеОформление.Элементы.Добавить();
	
	ОформляемоеПоле = ЭлементОформления.Поля.Элементы.Добавить();
	ОформляемоеПоле.Поле = Новый ПолеКомпоновкиДанных("Макеты");

	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ОтборПоЯзыку");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Заполнено;
		
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.ДоступныеЯзыки");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.НеСодержит;
	ЭлементОтбора.ПравоеЗначение = Новый ПолеКомпоновкиДанных("ОтборПоЯзыку");

	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.ЭтоГруппа");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Ложь;
	
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Отображать", Ложь);
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);	
	
	// ПоказыватьИзмененные
	
	ЭлементОформления = УсловноеОформление.Элементы.Добавить();
	
	ОформляемоеПоле = ЭлементОформления.Поля.Элементы.Добавить();
	ОформляемоеПоле.Поле = Новый ПолеКомпоновкиДанных("Макеты");
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ПоказыватьИзмененные");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Ложь;

	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.Изменен");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Истина;

	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.ЭтоГруппа");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Ложь;	
	
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Отображать", Ложь);
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);
	
	// ПоказыватьИспользуемые
	
	ЭлементОформления = УсловноеОформление.Элементы.Добавить();
	
	ОформляемоеПоле = ЭлементОформления.Поля.Элементы.Добавить();
	ОформляемоеПоле.Поле = Новый ПолеКомпоновкиДанных("Макеты");
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ПоказыватьИспользуемые");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Ложь;
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.Используется");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Истина;
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.ЭтоГруппа");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Ложь;	
	
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Отображать", Ложь);
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);
	
	// ПоказыватьНеизмененные
	
	ЭлементОформления = УсловноеОформление.Элементы.Добавить();
	
	ОформляемоеПоле = ЭлементОформления.Поля.Элементы.Добавить();
	ОформляемоеПоле.Поле = Новый ПолеКомпоновкиДанных("Макеты");
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ПоказыватьНеизмененные");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Ложь;
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.Изменен");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Ложь;
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.ЭтоГруппа");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Ложь;	
	
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Отображать", Ложь);
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);
	
	// ПоказыватьНеиспользуемые
	
	ЭлементОформления = УсловноеОформление.Элементы.Добавить();
	
	ОформляемоеПоле = ЭлементОформления.Поля.Элементы.Добавить();
	ОформляемоеПоле.Поле = Новый ПолеКомпоновкиДанных("Макеты");
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ПоказыватьНеиспользуемые");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Ложь;
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.Используется");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Ложь;
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Макеты.ЭтоГруппа");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = Ложь;	
	
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Отображать", Ложь);
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);
	
КонецПроцедуры

#КонецОбласти

