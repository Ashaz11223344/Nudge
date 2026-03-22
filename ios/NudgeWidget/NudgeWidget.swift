import WidgetKit
import SwiftUI
import AppIntents

struct RefreshQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Quote"
    
    func perform() async throws -> some IntentResult {
        // This is where we would trigger the background refresh.
        // home_widget uses a specific mechanism to trigger Dart code.
        UserDefaults(suiteName: "group.com.nudgeapp.nudge")?.set(true, forKey: "refresh_triggered")
        return .result()
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quote: "Stay strong, stay focused.", streak: 0, mood: "Feeling Good")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), quote: "The best way to predict the future is to create it.", streak: 7, mood: "Relaxed")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.nudgeapp.nudge")
        let quote = userDefaults?.string(forKey: "widget_quote") ?? "Stay strong, stay focused."
        let streak = userDefaults?.integer(forKey: "widget_streak") ?? 0
        let mood = userDefaults?.string(forKey: "widget_mood") ?? "Feeling Good"

        let entry = SimpleEntry(date: Date(), quote: quote, streak: streak, mood: mood)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quote: String
    let streak: Int
    let mood: String
}

struct NudgeWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color.widgetBackground
            
            VStack(alignment: .center, spacing: 8) {
                Text(entry.quote)
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(Color.widgetText)
                    .multilineTextAlignment(.center)
                    .lineLimit(family == .systemSmall ? 4 : 6)
                
                if family != .systemSmall {
                    Divider().background(Color.widgetAccent.opacity(0.3))
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("STREAK")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(Color.widgetText.opacity(0.6))
                            Text("\(entry.streak) Days")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.widgetAccent)
                        }
                        
                        Spacer()
                        
                        if family == .systemLarge {
                            VStack(alignment: .trailing) {
                                Text("MOOD")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(Color.widgetText.opacity(0.6))
                                Text(entry.mood)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.widgetText)
                            }
                        }
                    }
                }
                
                if #available(iOS 17.0, *) {
                    Button(intent: RefreshQuoteIntent()) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.widgetAccent)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
            }
            .padding()
        }
    }
}

extension Color {
    static let widgetBackground = Color(red: 255/255, green: 250/255, blue: 240/255)
    static let widgetText = Color(red: 62/255, green: 39/255, blue: 35/255)
    static let widgetAccent = Color(red: 211/255, green: 47/255, blue: 47/255)
}

@main
struct NudgeWidget: Widget {
    let kind: String = "NudgeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NudgeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Nudge")
        .description("Daily motivation on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
