///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды <configuration>
//
// (с) BIA Technologies, LLC
//
///////////////////////////////////////////////////////////////////////////////

#Использовать gitrunner
Перем Лог;

///////////////////////////////////////////////////////////////////////////////

Процедура НастроитьКоманду(Знач Команда, Знач Парсер) Экспорт

	// Добавление параметров команды
	Парсер.ДобавитьПараметрФлагКоманды(Команда, "-global", "Работа с глобальными настройками.");
	// TODO: пока оция не используется Парсер.ДобавитьИменованныйПараметрКоманды(Команда, "-rep-path", "Каталог репозитория, настройки которого интересуют.");
	Парсер.ДобавитьПараметрФлагКоманды(Команда, "-reset", "Сброс настроек на значения по умолчанию. Если редактируются настройки репозитория, то происходит удаление файла настроек.");
	Парсер.ДобавитьПараметрФлагКоманды(Команда, "-config", "Интерактивное конфигурирование настроек.");

КонецПроцедуры // НастроитьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   Приложение - Модуль - Модуль менеджера приложения
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач Приложение) Экспорт
	
	Лог = Приложение.ПолучитьЛог();
	Если НЕ ПараметрыКоманды["-global"] Тогда
			// TODO: Пока не используется И НЕ ЗначениеЗаполнено(ПараметрыКоманды["-rep-path"]) Тогда

		// TODO: пока не используется Лог.Ошибка("Для конфгурирования необходимо передать флаг -global или указать каталог репозитория параметром -rep-path");
		Лог.Ошибка("Для конфгурирования необходимо передать флаг -global");
		Возврат Приложение.РезультатыКоманд().НеверныеПараметры;

	КонецЕсли;
	
	Если ПараметрыКоманды["-global"] Тогда

		КаталогРепозитория = Приложение.ПутьКРодительскомуКаталогу();

	Иначе

		КаталогРепозитория = ПараметрыКоманды["-rep-path"];

	КонецЕсли;

	УправлениеНастройками = Новый НастройкиРепозитория(КаталогРепозитория);

	Если ПараметрыКоманды["-reset"] Тогда

		Если ПараметрыКоманды["-global"] Тогда

			ЗаписатьГлобальныеНастройкиПоУмолчанию(УправлениеНастройками, Приложение.КаталогСценариев());

		Иначе

			СброситьНастройкиРепозитория(УправлениеНастройками);

		КонецЕсли;

	ИначеЕсли ПараметрыКоманды["-config"] Тогда

		ИнтерактивнаяНастройка(КаталогРепозитория, УправлениеНастройками, ПараметрыКоманды["-global"], Приложение.КаталогСценариев());
	
	Иначе
		
		НапечататьНастройки(УправлениеНастройками);

	КонецЕсли;

	// При успешном выполнении возвращает код успеха
	Возврат Приложение.РезультатыКоманд().Успех;
	
КонецФункции // ВыполнитьКоманду

Процедура НапечататьНастройки(УправлениеНастройками)

	Если УправлениеНастройками.ЭтоНовый() Тогда

		Лог.Информация("Файл настроек не обнаружен");
		Возврат;

	КонецЕсли;

	НастройкиПрекоммита = УправлениеНастройками.НастройкиПриложения("Precommt4onecСценарии");
	Если НЕ ЗначениеЗаполнено(НастройкиПрекоммита) Тогда
	
		Лог.Информация("Настройки в файле отсутствуют");
		Возврат;

	КонецЕсли;

	Сообщить("Установленные настройки: ");

	Для Каждого НастройкаПрекоммита Из НастройкиПрекоммита Цикл

		Если ТипЗнч(НастройкаПрекоммита.Значение) = Тип("Массив") Тогда

			ЗначениеПараметра = СтрСоединить(НастройкаПрекоммита.Значение, ",");

		Иначе

			ЗначениеПараметра = НастройкаПрекоммита.Значение;

		КонецЕсли;

		Сообщить(Символы.Таб + НастройкаПрекоммита.Ключ + " = " + ЗначениеПараметра);

	КонецЦикла;

КонецПроцедуры

Процедура ЗаписатьГлобальныеНастройкиПоУмолчанию(УправлениеНастройками, ТекущийКаталогСценариев)

	ИмяПриложения = "Precommt4onecСценарии";
	СброситьНастройкиРепозитория(УправлениеНастройками);

	УправлениеНастройками.ЗаписатьНастройку(ИмяПриложения + "\ИспользоватьСценарииРепозитория", Ложь);
	УправлениеНастройками.ЗаписатьНастройку(ИмяПриложения + "\КаталогЛокальныхСценариев", "");

	ГлобальныеСценарии = ПолучитьИменаСценариев(ТекущийКаталогСценариев);
	УправлениеНастройками.ЗаписатьНастройку(ИмяПриложения + "\ГлобальныеСценарии", ГлобальныеСценарии);

КонецПроцедуры

Процедура СброситьНастройкиРепозитория(УправлениеНастройками)

	Если УправлениеНастройками.ЭтоНовый() Тогда

		Возврат;

	КонецЕсли;

	ИмяПриложения = "Precommt4onecСценарии";
	УправлениеНастройками.УдалитьНастройкиПриложения(ИмяПриложения);

КонецПроцедуры

Функция ПолучитьИменаСценариев(КаталогСценариев)

	НайденныеСценарии = Новый Массив;
	ФайлыСценариев = НайтиФайлы(КаталогСценариев, "*.os");
	Для Каждого ФайлСценария Из ФайлыСценариев Цикл		

		Если СтрСравнить(ФайлСценария.ИмяБезРасширения, "ШаблонСценария") = 0 Тогда
		
			Продолжить;

		КонецЕсли;

		НайденныеСценарии.Добавить(ФайлСценария.Имя);

	КонецЦикла;

	Возврат НайденныеСценарии;

КонецФункции

Процедура ИнтерактивнаяНастройка(КаталогРепозитория, УправлениеНастройками, ГлобальныеНастройки, КаталогГлобальныхСценариев)

	Сообщить("Настройка конфигурации precommit");
	Если ГлобальныеНастройки Тогда
	
		ГлобальныеСценарии = ПолучитьНастройкуМассив("Выберите подключаемые глобальные сценарии: ",  ПолучитьИменаСценариев(КаталогГлобальныхСценариев));
		ИспользоватьСценарииРепозитория = ПолучитьНастройкуБулево("Нужно использовать сценарии локальных репозиториев?", ЛОЖЬ);
		
		КаталогЛокальныхСценариев = "";
		Если ИспользоватьСценарииРепозитория Тогда

			КаталогЛокальныхСценариев = ПолучитьНастройкуСтрока("Укажите относительный путь к сценариям в репозитории: ");

		КонецЕсли;

		ИмяПриложения = "Precommt4onecСценарии";
		СброситьНастройкиРепозитория(УправлениеНастройками);
	
		УправлениеНастройками.ЗаписатьНастройку(ИмяПриложения + "\ИспользоватьСценарииРепозитория", ИспользоватьСценарииРепозитория);
		УправлениеНастройками.ЗаписатьНастройку(ИмяПриложения + "\КаталогЛокальныхСценариев", КаталогЛокальныхСценариев);
	
		УправлениеНастройками.ЗаписатьНастройку(ИмяПриложения + "\ГлобальныеСценарии", ГлобальныеСценарии);

	Иначе

		// todo
		// пока нет, будет в будущем

	КонецЕсли;

КонецПроцедуры

Функция ПолучитьНастройкуБулево(ТекстПодсказки, ЗначениеПоУмолчанию)

	ВыбранноеЗначение = Формат(ЗначениеПоУмолчанию, "БЛ=n; БИ=y");
	Пока ИСТИНА Цикл

		Сообщить(ТекстПодсказки + " [" + Формат(ЗначениеПоУмолчанию, "БЛ=n; БИ=y") + "]. Введите y[es]/n[o]");
		ВвестиСтроку(ВыбранноеЗначение);

		Если СтрНайти("yY", ВыбранноеЗначение) Тогда

			ВыбранноеЗначение = ИСТИНА;
			Прервать;

		ИначеЕсли СтрНайти("nN", ВыбранноеЗначение) Тогда
				
			ВыбранноеЗначение = ЛОЖЬ;
			Прервать;
			
		ИначеЕсли ВыбранноеЗначение = Символы.ПС Тогда
			
			ВыбранноеЗначение = ИСТИНА;
			Прервать;

		КонецЕсли;

	КонецЦикла;

	Возврат ВыбранноеЗначение;

КонецФункции

Функция ПолучитьНастройкуМассив(ТекстПодсказки, ДоступныйМассив)

	Сообщить(ТекстПодсказки);
	ВыбранныеЭлементы = Новый Массив;
	Для Ит = 0 По ДоступныйМассив.Количество() - 1 Цикл
	
		ЗначениеМассива = ДоступныйМассив[Ит];
		ТекстПодсказкиМассив = Символы.Таб + ЗначениеМассива;
		Если ПолучитьНастройкуБулево(ТекстПодсказкиМассив, ИСТИНА) Тогда

			ВыбранныеЭлементы.Добавить(ЗначениеМассива);

		КонецЕсли;

	КонецЦикла;
	
	Возврат ВыбранныеЭлементы;

КонецФункции

Функция ПолучитьНастройкуСтрока(ТекстПодсказки)
	
	ВыбранноеЗначение = "";
	Пока Истина Цикл
	
		Сообщить(ТекстПодсказки);
		ВвестиСтроку(ВыбранноеЗначение);
	
		ВыбранноеЗначение = СокрЛП(ВыбранноеЗначение);
		Если Не ПустаяСтрока(ВыбранноеЗначение) Тогда
			
			Прервать;
	
		КонецЕсли;

	КонецЦикла;

	Возврат ВыбранноеЗначение;
	
КонецФункции